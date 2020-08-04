from typing import List

from matplotlib.figure import Figure
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
import Plot
from classifier.evaluation.F1AUC.F1AUCModelEvaluator import F1AUCModelEvaluator
from classifier.evaluation.F1AUC.ThemeMetricF1AUCList import ThemeMetricF1AUCList
from classifier.evaluation.abstracts.ThemeMetricAggregator import ThemeMetricAggregator
from classifier.evaluation.abstracts.ModelEvaluator import ModelEvaluator
from classifier.prediction.ArticlesPrediction import ArticlesPrediction
from classifier.preprocessing.article_theme_tokenizer import ArticleThemeTokenizer


class ThemeMetricF1AUCAggregator(ThemeMetricAggregator):

    perThemeMetricsValidation: ThemeMetricF1AUCList = ThemeMetricF1AUCList()
    perThemeMetricsTrain: ThemeMetricF1AUCList = ThemeMetricF1AUCList()

    def __init__(self, themes: List[str], evaluator: F1AUCModelEvaluator):
        super(ThemeMetricAggregator, self).__init__()
        self.__supported_themes__ = themes
        self.evaluator = evaluator


    def evaluate(self,
                 predictions_train: ArticlesPrediction,
                 predictions_validation: ArticlesPrediction,
                 theme_tokenizer: ArticleThemeTokenizer):
        self.evaluator.set_theme_tokenizer(theme_tokenizer)

        for theme in self.__supported_themes__:
            metric_val = self.evaluator.evaluate_theme(theme, predictions_validation)
            self.perThemeMetricsValidation.add(theme, metric_val)

            metric_train = self.evaluator.evaluate_theme(theme, predictions_train)
            self.perThemeMetricsTrain.add(theme, metric_train)


    def plot(self):
        fig: Figure = plt.figure("plot_score_per_theme")

        plt.clf()
        plt.ion()

        ax = fig.subplots(len(self.__supported_themes__), 2, sharex="all", sharey="all")


        i = 0
        for theme in self.__supported_themes__:
            f1_validation = self.perThemeMetricsValidation.get_f1(theme)
            f1_train = self.perThemeMetricsTrain.get_f1(theme)

            auc_validation = self.perThemeMetricsValidation.get_auc(theme)
            auc_train = self.perThemeMetricsTrain.get_auc(theme)

            x = range(0, len(f1_train))

            if len(theme) == 1:
                ax[i, 0].plot(x, f1_validation, label="f1-validation")
                ax[i, 0].plot(x, f1_train, label="f1-train")

                ax[i, 1].plot(x, auc_validation, label="auc-validation")
                ax[i, 1].plot(x, auc_train, label="auc-train")

                ax[i, 0].set_title(theme)
                ax[i, 1].set_title(theme)
                ax[i, 1].legend()
                ax[i, 0].legend()
            else:
                ax[i].plot(x, f1_validation, label="f1-validation")
                ax[0].plot(x, f1_train, label="f1-train")

                ax[1].plot(x, auc_validation, label="auc-validation")
                ax[1].plot(x, auc_train, label="auc-train")

                ax[0].set_title(theme)
                ax[1].set_title(theme)
                ax[1].legend()
                ax[0].legend()



            i+=1

        fig.autofmt_xdate()
        plt.get_current_fig_manager().show()
        plt.pause(0.05)

        fig.show()
