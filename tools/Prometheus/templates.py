import re
from datetime import date
from typing import Dict


def render_template(template: str, context: Dict) -> str:
    result = template
    for key, value in context.items():
        if isinstance(value, date):
            value = value.strftime("%Y-%m-%d")
        result = result.replace(f"{{{key}}}", str(value))
    return result
