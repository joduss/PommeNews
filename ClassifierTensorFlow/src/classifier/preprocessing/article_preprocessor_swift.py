import subprocess
import tempfile

from classifier.preprocessing.interface_article_preprocessor import IArticlePreprocessor
from data_models.article import Article
from data_models.articles import Articles


class ArticlePreprocessorSwift(IArticlePreprocessor):
    """
    Preprocessor cleaning the article / data_models, by a swift program.
    """

    def process_articles(self, articles: Articles) -> Articles:
        """
        Remove stopwords and do lemmatization on each article, for the specified language.
        :param articles: data_models to process
        :return: processed data_models
        """
        return self.__execute_swift_program(articles)


    def process_article(self, article: Article) -> Article:
        """
        Remove stopwords and do lemmatization on one single article, for the specified language.
        :param article: article to process
        :return: processed article
        """
        return self.__execute_swift_program(Articles(article=article)).items[0]


    @staticmethod
    def __execute_swift_program(articles: Articles) -> Articles:
        (input_file, input_path) = tempfile.mkstemp()
        (output_file, output_path) = tempfile.mkstemp()

        articles.save(input_path)

        process = subprocess.Popen(
            ["./ArticlePreprocessorTool", input_path, output_path], stdout=subprocess.PIPE)
        while True:
            output = process.stdout.readline()
            if process.poll() is not None:
                break
            if output:
                print(output.strip())
        #rc = process.poll()

        return Articles.from_file(output_path)
