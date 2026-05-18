import re
import json

def parse():
    with open('scratch/raw_questions.txt', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    dimensions = []
    current_dim = None
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        if 'البعد' in line and ('🗣️' in line or '🏠' in line or '🤝' in line or '🏃' in line or '⚠️' in line):
            if current_dim:
                dimensions.append(current_dim)
            current_dim = {'title': line, 'questions': []}
        elif line[0].isdigit() and '. ' in line[:5]:
            if current_dim:
                current_dim['questions'].append(line)
        elif line[0].isdigit() and '- ' in line[:5]:
             # skip options
             pass
                
    if current_dim:
        dimensions.append(current_dim)
        
    dart_code = "class VinelandQuestions {\n"
    dart_code += "  static const List<Map<String, dynamic>> dimensions = [\n"
    
    for dim in dimensions:
        dart_code += "    {\n"
        dart_code += f"      'title': '{dim['title'].replace(chr(39), chr(92)+chr(39))}',\n"
        dart_code += "      'questions': [\n"
        for q in dim['questions']:
            dart_code += f"        '{q.replace(chr(39), chr(92)+chr(39))}',\n"
        dart_code += "      ],\n"
        dart_code += "    },\n"
        
    dart_code += "  ];\n"
    dart_code += "}\n"
    
    with open('lib/screens/vineland_questions.dart', 'w', encoding='utf-8') as f:
        f.write(dart_code)

if __name__ == '__main__':
    parse()
