from dataclasses import dataclass


@dataclass
class ThemeStat:

    theme: str
    article_count: int
    total_article_count : int

    def weight(self) -> float:
        raise Exception("To review")
        return self.article_count / (self.total_article_count - self.article_count)