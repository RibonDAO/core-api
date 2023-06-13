module Api
  module V1
    module News
      class ArticlesController < ApplicationController
        def index
          @articles = articles_list.order(sortable).page(page).per(per)

          render json: ArticleBlueprint.render(@articles, total_items:, page:, total_pages:)
        end

        def show
          @article = Article.find(params[:id])

          render json: ArticleBlueprint.render(@article)
        end

        def create
          command = Articles::CreateArticle.call(article_params)
          if command.success?
            render json: ArticleBlueprint.render(command.result), status: :created
          else
            render_errors(command.errors)
          end
        end

        def update
          command = Articles::UpdateArticle.call(article_params.merge(id: params[:id]))
          if command.success?
            render json: ArticleBlueprint.render(command.result)
          else
            render_errors(command.errors)
          end
        end

        private

        def articles_list
          return Article if params[:show_hidden_articles].present?

          Article.where(visible: true, published_at: ..Time.zone.now)
        end

        def sortable
          @sortable ||= params[:sort].present? ? "#{params[:sort]} #{sort_direction}" : 'created_at desc'
        end

        def sort_direction
          %w[asc desc].include?(params[:sort_dir]) ? params[:sort_dir] : 'asc'
        end

        def total_pages
          @articles.page(@page).total_pages
        end

        def total_items
          @total_items = @articles.count
        end

        def page
          @page = params[:page] || 1
        end

        def per
          @per = params[:per] || 100
        end

        def article_params
          params.permit(:title, :published_at, :image, :visible, :author_id, :id, :link, :language)
        end
      end
    end
  end
end
