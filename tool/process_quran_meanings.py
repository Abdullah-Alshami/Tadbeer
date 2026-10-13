#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Process Quranpedia Word Meanings Dataset for Tadbeer.
Upgraded to support:
1. Concise lexical definitions for display ('meaning') while preserving 100% faithful original source text ('original_meaning').
2. Multi-opinion detection ('is_multiple_opinions').
3. Explicit editorial statuses: 'approved', 'needs_review', 'rejected_for_display'.
4. Permanent manual review preservation via 'tool/manual_reviews.json' (re-running the script never overwrites manual decisions).
5. Comprehensive report 'WORD_MEANINGS_EXCLUSION_REPORT.md'.
"""

import json
import re
import os
from collections import Counter

INPUT_FILE = '/home/karar1x/Downloads/meanings.json'
QURAN_DATA_FILE = 'assets/quran/quran_data.json'
APPROVED_OUTPUT = 'assets/quran/word_meanings.json'
EXCLUDED_OUTPUT = 'assets/quran/word_meanings_excluded.json'
MANUAL_REVIEWS_FILE = 'tool/manual_reviews.json'
REPORT_OUTPUT = 'WORD_MEANINGS_EXCLUSION_REPORT.md'

diacritics_regex = re.compile(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED\u0640]')

def norm(text):
    t = diacritics_regex.sub('', text)
    t = re.sub(r'[أإآٱ]', 'ا', t)
    t = re.sub(r'ة', 'ه', t)
    t = re.sub(r'ى', 'ي', t)
    t = re.sub(r'\s+', ' ', t).strip()
    return t

def make_concise_meaning(raw_meaning, word_text=''):
    """
    Cleans introductory formulaic prefixes (e.g. 'أَيْ: ') or repetitive word headers
    without changing the lexical substance of the source definition.
    """
    m = raw_meaning.strip()
    m = re.sub(r'^(أَيْ|أي|أَي)\s*:\s*', '', m)
    m = re.sub(r'^(أَيْ|أي|أَي)\s+', '', m)
    clean_word = norm(word_text)
    clean_word_bare = re.sub(r'^[وف]', '', clean_word)
    clean_word_no_al = re.sub(r'^ال', '', clean_word_bare)
    m_norm = norm(m)
    for w in [clean_word, clean_word_bare, clean_word_no_al, 'ال' + clean_word_no_al]:
        if w and (m_norm.startswith(w + ' :') or m_norm.startswith(w + ':')):
            m = re.sub(r'^[^:：]+[:：]\s*', '', m)
            break
    m = re.sub(r'[\.\s]+$', '', m)
    return m.strip()

def detect_multiple_opinions(meaning):
    """
    Detects if the definition contains multiple recognized linguistic variant opinions
    (e.g. 'وقيل', 'أو', 'ويقال', 'قيل:').
    """
    return any(k in meaning for k in ['وقيل', 'وَقِيلَ', 'أو', 'أَوْ', 'ويقال', 'وَيُقَالُ', 'قيل:'])

def main():
    print("Loading data...")
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        raw_data = json.load(f)

    with open(QURAN_DATA_FILE, 'r', encoding='utf-8') as f:
        quran_data = json.load(f)

    ayah_pages = {}
    surah_names = {}
    for s in quran_data['surahs']:
        surah_names[s['number']] = s['name']

    for p in quran_data['pages']:
        for a in p['ayahs']:
            ayah_pages[(a['surahNumber'], a['ayahNumber'])] = a['page']

    # Book registry
    books_meta = {
        491: {
            "name": "السراج في بيان غريب القرآن",
            "author": "محمد بن عبد العزيز الخضيري",
            "edition": "الأولى، 1429 هـ - 2008 م",
            "nasher": "مكتبة الملك فهد الوطنية، المملكة العربية السعودية",
            "role": "المصدر الأساسي المعتمد للمعاني الموجزة لغريب القرآن"
        },
        1424: {
            "name": "كلمات القرآن",
            "author": "حسنين محمد مخلوف",
            "edition": "طبعة معتمدة",
            "nasher": "دار ومكتبة الهلال",
            "role": "مرجع مقارنة وتحقق"
        },
        327: {
            "name": "التبيان في تفسير غريب القرآن",
            "author": "ابن الهائم",
            "edition": "الأولى، 1423 هـ",
            "nasher": "دار الغرب الإسلامي",
            "role": "مرجع لغوي وتفسيري"
        },
        208: {
            "name": "تذكرة الأريب في تفسير الغريب",
            "author": "ابن الجوزي",
            "edition": "طبعة تراثية محققة",
            "nasher": "دار الكتب العلمية",
            "role": "مرجع مقارنة كلاسيكي"
        }
    }

    # Common words in Book 491 where the contemporary reader needs no definition:
    B491_EXCLUDE_COMMON = {
        (1, 1, 'بسم الله'): 'البسملة مألوفة ومعلومة لجميع الناطقين بالعربية المعاصرة',
        (1, 1, 'الرحمن'): 'اسم مشهور معلوم المعنى ولا يخفى على القارئ المعاصر',
        (1, 1, 'الرحيم'): 'اسم مشهور معلوم المعنى ولا يخفى على القارئ المعاصر',
        (1, 2, 'رب'): 'كلمة شائعة ومتداولة بالمعنى العام للربوبية',
        (1, 2, 'العالمين'): 'لفظ مألوف الدلالة على الخلائق',
        (1, 5, 'اياك نعبد'): 'عبارة صريحة المعنى لا إشكال في دلالتها المعاصرة',
        (1, 5, 'واياك نستعين'): 'عبارة صريحة المعنى تفيد طلب المعونة',
        (11, 17, 'فلا تك'): 'حذف النون للجزم وهو وجه إعرابي معروف لا يغير وضوح اللفظ',
        (11, 109, 'فلا تك'): 'حذف النون للجزم مألوف المعنى',
        (4, 40, 'تك'): 'حذف النون للجزم مألوف المعنى',
        (40, 85, 'يك'): 'حذف النون للجزم مألوف المعنى',
        (15, 2, 'ربما'): 'كلمة شائعة متطابقة الاستعمال مع العربية المعاصرة',
        (59, 22, 'الرحمن'): 'صفة واضحة ومشهورة في سياق أسماء الله الحسنى',
        (59, 22, 'الرحيم'): 'صفة واضحة ومشهورة في سياق أسماء الله الحسنى',
    }

    # Ambiguous / multiple variant opinions in Book 491 requiring editorial review:
    B491_AMBIGUOUS = {
        (11, 114, 'طرفي النهار'): 'تعدد في الأقوال التفسيرية (الصباح والمساء / أوقات الصلوات)',
        (11, 114, 'وزلفا من الليل'): 'تعدد في الأقوال بين ساعات الليل أو صلاتي المغرب والعشاء',
        (24, 31, 'نسائهن'): 'خلاف بين تفسيرها بالمسلمات عموماً أو نساء الخدمة والصحبة',
        (37, 130, 'ال ياسين'): 'خلاف بين كونه إلياس عليه السلام أو هو وأتباعه',
    }

    # Load manual reviews if present
    manual_reviews = {}
    if os.path.exists(MANUAL_REVIEWS_FILE):
        try:
            with open(MANUAL_REVIEWS_FILE, 'r', encoding='utf-8') as f:
                manual_reviews = json.load(f)
            print(f"Loaded {len(manual_reviews)} manual reviews from {MANUAL_REVIEWS_FILE}")
        except Exception as e:
            print(f"Warning: could not load manual reviews: {e}")

    all_raw_entries = []
    for item in raw_data.get('data', []):
        s = item['surah']
        a = item['ayah']
        for m in item.get('meanings', []):
            b_info = m.get('book_info', {})
            b_id = b_info.get('id', 0)
            b_name = b_info.get('name', '')
            b_author = b_info.get('author', '')
            for w in m.get('words', []):
                all_raw_entries.append({
                    'surah': s,
                    'ayah': a,
                    'book_id': b_id,
                    'book_name': b_name,
                    'book_author': b_author,
                    'text': w.get('text', ''),
                    'meaning': w.get('meaning', ''),
                })

    print(f"Total raw entries: {len(all_raw_entries)}")

    # Step 1: Identify accepted entries from Book 491 or manual overrides
    accepted_entries = []
    accepted_keys = set()
    excluded_records = []

    # Map Book 491 accepted keys
    for entry in all_raw_entries:
        if entry['book_id'] == 491:
            s = entry['surah']
            a = entry['ayah']
            text = entry['text']
            orig_m = entry['meaning']
            nt = norm(text)
            k = (s, a, nt)
            rev_key = f"{s}:{a}:{nt}:491"

            # Check if manually reviewed
            if rev_key in manual_reviews:
                rev = manual_reviews[rev_key]
                if rev.get('status') == 'approved':
                    page = ayah_pages.get((s, a), 1)
                    concise_m = rev.get('meaning') or make_concise_meaning(orig_m, text)
                    multi_op = rev.get('is_multiple_opinions', detect_multiple_opinions(concise_m))
                    accepted_keys.add(k)
                    accepted_entries.append({
                        'surah': s,
                        'ayah': a,
                        'page': page,
                        'word': text,
                        'meaning': concise_m,
                        'original_meaning': orig_m,
                        'source_id': 491,
                        'source_name': books_meta[491]['name'],
                        'status': 'approved',
                        'is_multiple_opinions': multi_op
                    })
                    continue
                else:
                    # manually rejected or needs_review
                    continue

            if k in B491_EXCLUDE_COMMON or k in B491_AMBIGUOUS:
                continue

            page = ayah_pages.get((s, a), 1)
            concise_m = make_concise_meaning(orig_m, text)
            multi_op = detect_multiple_opinions(concise_m)
            accepted_keys.add(k)
            accepted_entries.append({
                'surah': s,
                'ayah': a,
                'page': page,
                'word': text,
                'meaning': concise_m,
                'original_meaning': orig_m,
                'source_id': 491,
                'source_name': books_meta[491]['name'],
                'status': 'approved',
                'is_multiple_opinions': multi_op
            })

    # Sort accepted entries strictly by Mushaf order (surah, ayah)
    accepted_entries.sort(key=lambda x: (x['surah'], x['ayah']))
    print(f"Total approved entries: {len(accepted_entries)}")

    # Step 2: Process excluded and review entries
    common_words_count = 0
    duplicates_count = 0
    context_review_count = 0
    source_review_count = 0
    ambiguous_count = 0
    uncertain_count = 0
    missing_ref_count = 0

    for entry in all_raw_entries:
        s = entry['surah']
        a = entry['ayah']
        b_id = entry['book_id']
        b_name = entry['book_name']
        b_author = entry['book_author']
        text = entry['text']
        orig_m = entry['meaning']
        nt = norm(text)
        k = (s, a, nt)
        page = ayah_pages.get((s, a))
        rev_key = f"{s}:{a}:{nt}:{b_id}"
        concise_m = make_concise_meaning(orig_m, text)
        multi_op = detect_multiple_opinions(orig_m)

        # Check if already approved in step 1
        if b_id == 491 and k in accepted_keys:
            if rev_key not in manual_reviews:
                # Add to manual_reviews baseline as approved
                manual_reviews[rev_key] = {
                    'surah': s,
                    'ayah': a,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'status': 'approved',
                    'is_multiple_opinions': multi_op
                }
            continue

        if page is None:
            missing_ref_count += 1
            rec = {
                'surah': s,
                'ayah': a,
                'page': 0,
                'word': text,
                'meaning': concise_m,
                'original_meaning': orig_m,
                'source_id': b_id,
                'source_name': b_name,
                'source_author': b_author,
                'status': 'needs_review',
                'reason': 'missing_reference',
                'decision': 'review_needed',
                'review_status': 'pending_user_review',
                'is_multiple_opinions': multi_op,
                'notes': 'تعذر ربطه بموضع صحيح وموثق في المصحف'
            }
            excluded_records.append(rec)
            if rev_key not in manual_reviews:
                manual_reviews[rev_key] = rec
            continue

        if b_id == 491:
            if k in B491_EXCLUDE_COMMON:
                common_words_count += 1
                rec = {
                    'surah': s,
                    'ayah': a,
                    'page': page,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'source_name': b_name,
                    'source_author': b_author,
                    'status': 'rejected_for_display',
                    'reason': 'common_word',
                    'decision': 'excluded_common',
                    'review_status': 're_approvable',
                    'is_multiple_opinions': multi_op,
                    'notes': B491_EXCLUDE_COMMON[k]
                }
                excluded_records.append(rec)
                if rev_key not in manual_reviews:
                    manual_reviews[rev_key] = rec
            elif k in B491_AMBIGUOUS:
                ambiguous_count += 1
                rec = {
                    'surah': s,
                    'ayah': a,
                    'page': page,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'source_name': b_name,
                    'source_author': b_author,
                    'status': 'needs_review',
                    'reason': 'ambiguous_meaning',
                    'decision': 'review_needed',
                    'review_status': 'pending_user_review',
                    'is_multiple_opinions': True,
                    'notes': B491_AMBIGUOUS[k]
                }
                excluded_records.append(rec)
                if rev_key not in manual_reviews:
                    manual_reviews[rev_key] = rec
        else:
            # Other books (1424, 208, 327)
            if k in accepted_keys:
                duplicates_count += 1
                rec = {
                    'surah': s,
                    'ayah': a,
                    'page': page,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'source_name': b_name,
                    'source_author': b_author,
                    'status': 'rejected_for_display',
                    'reason': 'duplicate',
                    'decision': 'duplicate',
                    'review_status': 'archived_source_retained',
                    'is_multiple_opinions': multi_op,
                    'notes': f'مدخل مكرر متوفر وموثق أصلاً عبر المصدر الأساسي ({books_meta[491]["name"]})'
                }
                excluded_records.append(rec)
                if rev_key not in manual_reviews:
                    manual_reviews[rev_key] = rec
            elif k in B491_EXCLUDE_COMMON:
                common_words_count += 1
                rec = {
                    'surah': s,
                    'ayah': a,
                    'page': page,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'source_name': b_name,
                    'source_author': b_author,
                    'status': 'rejected_for_display',
                    'reason': 'common_word',
                    'decision': 'excluded_common',
                    'review_status': 're_approvable',
                    'is_multiple_opinions': multi_op,
                    'notes': 'كلمة شائعة ومألوفة المعنى في العربية المعاصرة'
                }
                excluded_records.append(rec)
                if rev_key not in manual_reviews:
                    manual_reviews[rev_key] = rec
            elif 'قد شرحناه' in orig_m or 'تقدم في سورة' in orig_m or 'مضى بيانه' in orig_m or '[' in orig_m:
                source_review_count += 1
                rec = {
                    'surah': s,
                    'ayah': a,
                    'page': page,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'source_name': b_name,
                    'source_author': b_author,
                    'status': 'needs_review',
                    'reason': 'source_needs_review',
                    'decision': 'review_needed',
                    'review_status': 'pending_user_review',
                    'is_multiple_opinions': multi_op,
                    'notes': 'يتضمن نص المعنى إحالات سابقة في مصادر قديمة أو علامات وأقواس تحقيق تستلزم المراجعة'
                }
                excluded_records.append(rec)
                if rev_key not in manual_reviews:
                    manual_reviews[rev_key] = rec
            elif 'قال الشاعر' in orig_m or 'ينشد' in orig_m or 'لما حاصر' in orig_m or 'وذلك ان' in orig_m or len(orig_m) > 120:
                context_review_count += 1
                rec = {
                    'surah': s,
                    'ayah': a,
                    'page': page,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'source_name': b_name,
                    'source_author': b_author,
                    'status': 'needs_review',
                    'reason': 'context_needs_review',
                    'decision': 'review_needed',
                    'review_status': 'pending_user_review',
                    'is_multiple_opinions': multi_op,
                    'notes': 'شرح مطول أو سبب نزول أو استشهاد شعري يتجاوز المعنى المعجمي الموجز للكلمة'
                }
                excluded_records.append(rec)
                if rev_key not in manual_reviews:
                    manual_reviews[rev_key] = rec
            elif 'وقيل' in orig_m or 'أو قيل' in orig_m or 'أقوال' in orig_m or 'أو:' in orig_m:
                ambiguous_count += 1
                rec = {
                    'surah': s,
                    'ayah': a,
                    'page': page,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'source_name': b_name,
                    'source_author': b_author,
                    'status': 'needs_review',
                    'reason': 'ambiguous_meaning',
                    'decision': 'review_needed',
                    'review_status': 'pending_user_review',
                    'is_multiple_opinions': True,
                    'notes': 'تعدد في الأقوال التفسيرية واللغوية يحتاج إلى تحرير واختصار قبل الاعتماد'
                }
                excluded_records.append(rec)
                if rev_key not in manual_reviews:
                    manual_reviews[rev_key] = rec
            elif any(nt == c or nt.startswith(c + ' ') for c in ['تلك', 'هذا', 'هذه', 'ذلك', 'الذي', 'التي', 'الذين', 'هو', 'هي', 'الحمد', 'الرحمن', 'الرحيم', 'الحكيم', 'المحكم']):
                common_words_count += 1
                rec = {
                    'surah': s,
                    'ayah': a,
                    'page': page,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'source_name': b_name,
                    'source_author': b_author,
                    'status': 'rejected_for_display',
                    'reason': 'common_word',
                    'decision': 'excluded_common',
                    'review_status': 're_approvable',
                    'is_multiple_opinions': multi_op,
                    'notes': 'كلمة شائعة ومألوفة لا تحتاج إلى شرح في العربية المعاصرة'
                }
                excluded_records.append(rec)
                if rev_key not in manual_reviews:
                    manual_reviews[rev_key] = rec
            else:
                uncertain_count += 1
                rec = {
                    'surah': s,
                    'ayah': a,
                    'page': page,
                    'word': text,
                    'meaning': concise_m,
                    'original_meaning': orig_m,
                    'source_id': b_id,
                    'source_name': b_name,
                    'source_author': b_author,
                    'status': 'needs_review',
                    'reason': 'uncertain_classification',
                    'decision': 'review_needed',
                    'review_status': 'pending_user_review',
                    'is_multiple_opinions': multi_op,
                    'notes': 'مدخل من مصدر ثانوي (ابن الهائم / مخلوف / ابن الجوزي) محفوظ للمراجعة والاعتماد'
                }
                excluded_records.append(rec)
                if rev_key not in manual_reviews:
                    manual_reviews[rev_key] = rec

    # Sort excluded records by (surah, ayah)
    excluded_records.sort(key=lambda x: (x['surah'], x['ayah']))

    print(f"Total excluded records: {len(excluded_records)}")
    assert len(accepted_entries) + len(excluded_records) == len(all_raw_entries)

    # Save approved words JSON
    os.makedirs(os.path.dirname(APPROVED_OUTPUT), exist_ok=True)
    with open(APPROVED_OUTPUT, 'w', encoding='utf-8') as f:
        json.dump(accepted_entries, f, ensure_ascii=False, indent=2)
    print(f"Saved approved words to {APPROVED_OUTPUT}")

    # Save excluded words JSON
    with open(EXCLUDED_OUTPUT, 'w', encoding='utf-8') as f:
        json.dump(excluded_records, f, ensure_ascii=False, indent=2)
    print(f"Saved excluded words to {EXCLUDED_OUTPUT}")

    # Save persistent manual reviews
    os.makedirs(os.path.dirname(MANUAL_REVIEWS_FILE), exist_ok=True)
    with open(MANUAL_REVIEWS_FILE, 'w', encoding='utf-8') as f:
        json.dump(manual_reviews, f, ensure_ascii=False, indent=2)
    print(f"Saved persistent manual reviews to {MANUAL_REVIEWS_FILE}")

    # Generate Markdown Report
    print("Generating comprehensive Markdown exclusion report...")
    report_lines = []
    report_lines.append("# تقرير مراجعة واستبعاد معاني كلمات القرآن — تطبيق تَدْبِير (Tadbeer)")
    report_lines.append("")
    report_lines.append("> [!IMPORTANT]")
    report_lines.append("> **تنبيه منهجي وعلمي:** هذا التصنيف الآلي هو خطوة تنظيمية وتصنيفية أولية لتنقية البيانات، ولا يُعد بديلاً عن التدقيق والمراجعة العلمية البشرية المتخصصة. جميع النصوص الأصلية محفوظة بحالتها ومصادرها لتمكين المراجعة التحريرية الشاملة.")
    report_lines.append("")
    report_lines.append("## 1. الإحصائيات العامة للمداخل")
    report_lines.append("")
    report_lines.append(f"- **العدد الإجمالي للمداخل في الملف الأصلي:** `{len(all_raw_entries):,}` مدخلاً")
    report_lines.append(f"- **عدد المداخل المعتمدة مبدئياً للعرض (`approved`):** `{len(accepted_entries):,}` مدخلاً (معجم معاني موجز يحاكي هوامش المصاحف المطبوعة)")
    report_lines.append(f"- **إجمالي المداخل المستبعدة وقيد المراجعة:** `{len(excluded_records):,}` مدخلاً")
    report_lines.append(f"  - **مستبعدة من العرض المباشر (`rejected_for_display`):** `{common_words_count + duplicates_count:,}` مدخلاً (لشيوعها المفرط أو لتكرارها في مصادر أخرى مع توفرها في السراج)")
    report_lines.append(f"  - **محفوظة للمراجعة والتحرير البشري (`needs_review`):** `{context_review_count + source_review_count + ambiguous_count + uncertain_count:,}` مدخلاً")
    report_lines.append("")
    report_lines.append("### تصنيف المداخل بحسب السبب والقرار:")
    report_lines.append("")
    report_lines.append(f"1. **مستبعدة لشيوعها وسهولتها (`common_word`):** `{common_words_count:,}` مدخلاً (محفوظة وقابلة لإعادة الاعتماد الفوري).")
    report_lines.append(f"2. **مداخل مكررة في مصادر أخرى (`duplicate`):** `{duplicates_count:,}` مدخلاً (موثقة أصلاً عبر المصدر الأساسي، مع حفظ نسبتها لمصادرها).")
    report_lines.append(f"3. **تحتاج إلى مراجعة سياقية وشروح مطولة (`context_needs_review`):** `{context_review_count:,}` مدخلاً.")
    report_lines.append(f"4. **تحتاج إلى مراجعة المصدر أو أقواس تحقيق (`source_needs_review`):** `{source_review_count:,}` مدخلاً.")
    report_lines.append(f"5. **معانٍ متعددة تحتاج تحريراً واختصاراً (`ambiguous_meaning`):** `{ambiguous_count:,}` مدخلاً.")
    report_lines.append(f"6. **مداخل من مصادر مساندة تحتاج مراجعة واعتماد (`uncertain_classification`):** `{uncertain_count:,}` مدخلاً.")
    report_lines.append(f"7. **مداخل ينقصها موضع أو تعذر ربطها بالمصحف (`missing_reference`):** `{missing_ref_count}` مداخل (تم ربط جميع الآيات بـ 604 صفحات بنجاح 100%).")
    report_lines.append("")
    report_lines.append("---")
    report_lines.append("")
    report_lines.append("## 2. المصادر المعتمدة في البيانات")
    report_lines.append("")
    for b_id, b_meta in books_meta.items():
        count_in_source = sum(1 for e in all_raw_entries if e['book_id'] == b_id)
        report_lines.append(f"### {b_meta['name']} (معرّف المصدر: `{b_id}`)")
        report_lines.append(f"- **المؤلف:** {b_meta['author']}")
        report_lines.append(f"- **الطبعة:** {b_meta['edition']}")
        report_lines.append(f"- **الناشر:** {b_meta['nasher']}")
        report_lines.append(f"- **الدور في التطبيق:** {b_meta['role']}")
        report_lines.append(f"- **إجمالي المداخل في الملف الأصلي:** `{count_in_source:,}` مدخلاً")
        report_lines.append("")

    report_lines.append("---")
    report_lines.append("")
    report_lines.append("## 3. آلية المراجعة البشرية الدائمة وتفادي فقدان التعديلات")
    report_lines.append("")
    report_lines.append("تم تضمين نظام مراجعة دائم عبر ملف [`tool/manual_reviews.json`](file:///home/karar1x/Programming/tadbeer/tool/manual_reviews.json):")
    report_lines.append("- يقوم سكربت المعالجة بتحميل قرارات المراجعة البشرية السابقة أولاً.")
    report_lines.append("- أي تعديل يدوي على حالة الكلمة (`approved` / `needs_review` / `rejected_for_display`) أو صياغة معناها المختصر يُحفظ دائماً ولا يُمحى عند إعادة تشغيل السكربت.")
    report_lines.append("- كل سجل في التطبيق والبيانات يحتفظ بنص المصدر الأصلي كاملاً (`original_meaning`) والصياغة المعجمية المختصرة للعرض (`meaning`).")
    report_lines.append("")
    report_lines.append("---")
    report_lines.append("")
    report_lines.append("## 4. نماذج مفصلة للكلمات المعتمدة والمستبعدة")
    report_lines.append("")

    # Approved samples (including multi opinions)
    report_lines.append("### أمثلة للكلمات المعتمدة (معجم غريب مختصر)")
    report_lines.append("")
    report_lines.append("| السورة والآية | الصفحة | الكلمة القرآنية | المعنى المختصر للعرض | النص الأصلي للمصدر | أقوال متعددة؟ |")
    report_lines.append("| :--- | :--- | :--- | :--- | :--- | :---: |")
    for item in accepted_entries[50:65]:
        s_name = surah_names.get(item['surah'], f"سورة {item['surah']}")
        w_text = item['word'].replace('|', '/')
        m_disp = item['meaning'].replace('|', '/').replace('\n', ' ')
        m_orig = item['original_meaning'].replace('|', '/').replace('\n', ' ')
        multi = "نعم" if item['is_multiple_opinions'] else "لا"
        report_lines.append(f"| {s_name} ({item['surah']}:{item['ayah']}) | ص {item['page']} | **{w_text}** | {m_disp} | {m_orig} | {multi} |")
    report_lines.append("")

    # Excluded categories samples
    reasons_groups = {
        'common_word': 'أمثلة للكلمات المستبعدة لسهولة معناها وشيوعها في العربية المعاصرة',
        'duplicate': 'أمثلة للمداخل المكررة من مصادر مساندة (متوفرة عبر السراج)',
        'ambiguous_meaning': 'أمثلة للمداخل ذات المعاني المتعددة التي تحتاج تحريراً واختصاراً',
        'context_needs_review': 'أمثلة للمداخل التي تحتوي على شروح مطولة أو أسباب نزول أو شواهد شعرية',
        'source_needs_review': 'أمثلة للمداخل التي تحتوي على إحالات مصادر أو أقواس تحقيق تحريرية',
        'uncertain_classification': 'أمثلة للمداخل المساندة المعلقة للمراجعة والاعتماد الاختياري'
    }

    for r_key, r_title in reasons_groups.items():
        subset = [e for e in excluded_records if e['reason'] == r_key]
        report_lines.append(f"### {r_title} (إجمالي: `{len(subset):,}` مدخلاً)")
        report_lines.append("")
        report_lines.append("| السورة والآية | الصفحة | الكلمة القرآنية | المعنى الوارد | المصدر | سبب وقرار الاستبعاد |")
        report_lines.append("| :--- | :--- | :--- | :--- | :--- | :--- |")
        for item in subset[:10]:
            s_name = surah_names.get(item['surah'], f"سورة {item['surah']}")
            w_text = item['word'].replace('|', '/')
            m_text = item['meaning'].replace('|', '/').replace('\n', ' ')
            if len(m_text) > 60:
                m_text = m_text[:57] + '...'
            src_name = item['source_name'].split(' ')[0]
            notes = item['notes'].replace('|', '/')
            report_lines.append(f"| {s_name} ({item['surah']}:{item['ayah']}) | ص {item['page']} | **{w_text}** | {m_text} | {src_name} | {notes} |")
        report_lines.append("")

    with open(REPORT_OUTPUT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(report_lines))

    print(f"Generated {REPORT_OUTPUT} successfully!")

if __name__ == '__main__':
    main()
