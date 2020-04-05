from dataclasses import dataclass
from typing import List, Dict



class Article:

    title: str
    summary: str

    themes: List[str]
    predicted_themes: List[str]
    verified_themes: List[str]

    def __init__(self, title: str, summary: str, themes: List[str], predicted_themes: List[str], verified_themes: List[str]):
        self.title = title
        self.summary = summary
        self.themes = themes
        self.predicted_themes = predicted_themes
        self.verified_themes = verified_themes

    def copy(self):
        return Article(
            self.title,
            self.summary,
            self.themes,
            self.predicted_themes,
            self.verified_themes,
        )

    def title_and_summary(self) -> str:
        return self.title + "." + self.summary
