import os
import subprocess
import tempfile
from logging import getLogger
import tracemalloc

tracemalloc.start()

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
        while(True):
            try:
                return self.__execute_swift_program(Articles(article=article)).items[0]
            except:
                continue



    @staticmethod
    def __execute_swift_program(articles: Articles) -> Articles:
        (input_file, input_path) = tempfile.mkstemp()
        (output_file, output_path) = tempfile.mkstemp()

        os.close(input_file)
        os.close(output_file)

        articles.save(input_path)
        getLogger().info(f"Articles about to be processed available at {input_path}.")

        command_directory = os.path.dirname(os.path.abspath(__file__))
        command_path = f"{command_directory}/ArticlePreprocessorTool"

        with subprocess.Popen([command_path, input_path, output_path], stdout=subprocess.PIPE) as process:
            while True:
                output = process.stdout.readline()
                #print(output)
                if process.poll() is not None:
                    break
                if output:
                    print(output.strip(), end="\r")

        print("", end="\r")
        getLogger().info("Finished processing %d articles.", articles.count())

        getLogger().info(f"Preprocessed articles available at {output_path}.")

        return Articles.from_file(output_path)
