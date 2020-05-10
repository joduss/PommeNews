from typing import List

import numpy as np
from keras_preprocessing.text import Tokenizer

from data_models.articles import Articles


class ArticleThemeTokenizer:

    '''
    List of themes in the same order as in the tokenizer, which corresponds as well
    as the index of theme in the prediction
    '''
    orderedThemes: List[str]
    themes_count: int
    tokenizer: Tokenizer


    def __init__(self, articles: Articles):
        self.tokenizer = Tokenizer()
        self.tokenizer.fit_on_texts(articles.themes())

        self.one_hot_matrix = self.tokenizer.texts_to_matrix(articles.themes())

        # Remove the first column, whose first col contains only 0s.
        self.one_hot_matrix = np.delete(arr=self.one_hot_matrix, obj=0, axis=1)

        # Create ordered list of theme as in tokenizer
        self.orderedThemes: List[str] = []

        for i in range(1, len(self.tokenizer.word_index) + 1):  # word_index start at 1, 0 is reserved.
            self.orderedThemes.append(self.tokenizer.index_word[i])

        self.themes_count = len(self.tokenizer.word_index)



    def indexOfTheme(self, theme: str):
        return self.tokenizer.word_index[theme] - 1