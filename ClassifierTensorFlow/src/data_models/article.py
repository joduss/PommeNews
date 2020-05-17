from dataclasses import dataclass
from typing import List, Dict



class Article:

    id: str
    title: str
    summary: str

    themes: List[str]
    predicted_themes: List[str]
    verified_themes: List[str]

    def __init__(self, id: str, title: str, summary: str, themes: List[str], predicted_themes: List[str], verified_themes: List[str]):
        self.id = id
        self.title = title
        self.summary = summary
        self.themes = themes
        self.predicted_themes = predicted_themes
        self.verified_themes = verified_themes

    def copy(self):
        return Article(
            self.id,
            self.title,
            self.summary,
            self.themes.copy(),
            self.predicted_themes.copy(),
            self.verified_themes.copy(),
        )

    def title_and_summary(self) -> str:
        return self.title + ". " + self.summary
