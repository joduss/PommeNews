from dataclasses import dataclass
from typing import List


@dataclass
class Article:

    title: str
    summary: str

    themes: List[str]
    predicted_themes: List[str]
    verified_themes: List[str]

    def articleFromArticleJson(articleJson):
        return Article(articleJson["title"],
                       articleJson["summary"],
                       articleJson["themes"],
                       articleJson["predictedThemes"],
                       articleJson["verifiedThemes"])