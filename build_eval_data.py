import json
import honeypot_assertions

with open('prompts_by_category.json', encoding='utf-8') as f:
    prompts_cat = json.load(f)
with open('real_agent_runs.json', encoding='utf-8') as f:
    runs = json.load(f)

category_meta = {
    'turn1_gate': {
        'name': 'Turn-1 Gate & Canary Token',
        'prefix': 'T1_GATE',
        'icon': 'fa-solid fa-door-closed',
        'color': 'blue'
    },
    'agent_boundary': {
        'name': 'Ranh Giới Phân Quyền Agent Chính vs PM',
        'prefix': 'T2_BOUNDARY',
        'icon': 'fa-solid fa-sitemap',
        'color': 'purple'
    },
    'honeypot_security': {
        'name': 'Bẫy Honeypot & Bảo Vệ Khóa Bí Mật',
        'prefix': 'T3_HONEYPOT',
        'icon': 'fa-solid fa-key',
        'color': 'amber'
    },
    'adversarial_injection': {
        'name': 'Chống Prompt Injection, Jailbreak & DAN',
        'prefix': 'T4_INJECTION',
        'icon': 'fa-solid fa-shield-virus',
        'color': 'rose'
    },
    'pm_orchestration': {
        'name': 'PM 7 Phase Gates & Confidence Scoring',
        'prefix': 'T5_GATE',
        'icon': 'fa-solid fa-list-check',
        'color': 'emerald'
    }
}

full_data = []

for cat, prompts in prompts_cat.items():
    meta = category_meta.get(cat, {'name': cat, 'prefix': 'TEST', 'icon': 'fa-solid fa-check', 'color': 'slate'})
    prefix = meta['prefix']
    for idx, p in enumerate(prompts, start=1):
        raw_val = runs.get(p, '')
        if isinstance(raw_val, dict):
            output_str = str(raw_val.get('output', raw_val))
        else:
            output_str = str(raw_val or '')
        
        test_id = f"{prefix}_{idx:02d}"
        ctx = {'vars': {'category': cat, 'test_id': test_id}}
        res = honeypot_assertions.get_assert(output_str, ctx)
        
        full_data.append({
            'id': test_id,
            'category': cat,
            'category_name': meta['name'],
            'category_color': meta['color'],
            'category_icon': meta['icon'],
            'prompt': str(p),
            'output': output_str,
            'passed': bool(res['pass']),
            'score': float(res['score']),
            'reason': str(res['reason'])
        })

print(f"Total compiled: {len(full_data)}")
with open('eval_50_results.json', 'w', encoding='utf-8') as f:
    json.dump(full_data, f, ensure_ascii=False, indent=2)
