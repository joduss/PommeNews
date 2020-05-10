from typing import List

from classifier.preprocessing.article_theme_tokenizer import ArticleThemeTokenizer
from data_models.ThemeStat import ThemeStat


class ThemeWeights:

    theme_stats: List[ThemeStat]
    theme_tokenizer: ArticleThemeTokenizer

    def __init__(self, theme_stats: List[ThemeStat], theme_tokenizer: ArticleThemeTokenizer):
        self.theme_stats = theme_stats
        self.theme_tokenizer = theme_tokenizer


    def to_weights(self) -> List[float]:
        theme_weight: List[float] = list([])

        for theme in self.theme_tokenizer.orderedThemes:
            stat = [stat for stat in self.theme_stats if stat.theme == theme][0]
            theme_weight.append(1 / stat.weight())

        return theme_weight

