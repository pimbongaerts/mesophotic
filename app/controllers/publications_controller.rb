class PublicationsController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:pdfs, :show, :index, :behind, :publication_authors, :publication_keywords]
  before_action :set_publication, only: [:show, :edit, :edit_meta, :update,
                                         :behind, :destroy, :detach_field,
                                         :detach_focusgroup, :detach_platform,
                                         :detach_location, :add_validation,
                                         :remove_validation, :touch_validation,
                                         :behind_edit, :publication_authors]
  before_action :touch_publication, only: [:detach_field, :detach_focusgroup,
                                           :detach_platform, :detach_location]
  before_action :contents_convert_utf8, only: [:edit]
  before_action :empty_unused_fields, only: [:edit, :edit_meta, :update]

  def index
    respond_to do |format|
      params[:search_params] = search_params(params[:search_params]) || Publication.default_search_params
      args = params[:validation_type] == 'expired' ? [current_user] : []

      @publications = Publication.send(params[:validation_type] || :all, *args)
                                  .search(params[:search], params[:search_params], is_editor_or_admin)
      format.html {
        @publications = @publications.page(params[:page]).per(is_editor_or_admin ? 100 : 20)

        unless current_user.try(:editor_or_admin?) || params[:search_term].present?
          @locations = Location
            .select('locations.id')
            .joins(:publications)
            .group('locations.id')
            .order('count(locations.id) DESC')
            .map(&:id)
            .join(',')
          @platforms = Platform
            .select('platforms.description, platforms.short_description, count(platforms.id) AS count')
            .joins(:publications)
            .group('platforms.id')
            .order('count DESC')
            .limit(8)
          @focusgroups = Focusgroup
            .select('focusgroups.description, focusgroups.short_description, count(focusgroups.id) AS count')
            .joins(:publications)
            .group('focusgroups.id')
            .order('count DESC')
            .limit(8)
          @fields = Field
            .select('fields.description, fields.short_description, count(fields.id) AS count')
            .joins(:publications)
            .group('fields.id')
            .order('count DESC')
            .limit(8)
        end
      }

      format.csv {
        send_data @publications.reorder(:id).csv
      }
    end
  end

  def show
  end

  def pdfs
    respond_to do |format|
      format.png { send_non_public_file params }
      format.pdf {
        if current_user
          send_non_public_file params
        else
          redirect_to new_user_session_path
        end
      }
    end
  end

  def send_non_public_file params
    send_file "#{Rails.root}/publications/pdfs/#{params[:path]}/#{params[:filename]}", disposition: 'inline'
  end

  def behind
    @post = Post.friendly.find_by_featured_publication_id(params[:id])
    redirect_to root_path unless @post.present?
  rescue
    redirect_to root_path
  end

  def new
    @publication = Publication.new
  end

  def edit
  end

  def edit_meta
  end

  def create
    @publication = Publication.new(publication_params)
    @publication.contributor = current_user

    respond_to do |format|
      if @publication.save
        format.html { redirect_to edit_meta_publication_path(@publication),
                      notice: 'Publication was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @publication.update(publication_params)
        format.html { redirect_back fallback_location: root_path,
                      notice: 'Publication was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @publication.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path,
                    notice: 'Publication was successfully destroyed.' }
    end
  end

  def detach_field
      @publication.fields.delete(params[:format])
      redirect_back fallback_location: root_path,
                    notice: 'Field was successfully removed.'
  end

  def detach_focusgroup
      @publication.focusgroups.delete(params[:format])
      redirect_back fallback_location: root_path,
                    notice: 'Focusgroup was successfully removed.'
  end

  def detach_platform
      @publication.platforms.delete(params[:format])
      redirect_back fallback_location: root_path,
                    notice: 'Platform was successfully removed.'
  end

  def detach_location
      @publication.locations.delete(params[:format])
      redirect_back fallback_location: root_path,
                    notice: 'Location was successfully removed.'
  end

  def add_validation
      @publication.validations.build(user_id: params[:format]).save!
      redirect_back fallback_location: root_path,
                    notice: 'Publication was successfully validated.'
  end

  def remove_validation
      @publication.validations.find_by_user_id(params[:format]).delete
      redirect_back fallback_location: root_path,
                    notice: 'Validation was successfully removed.'
  end

  def touch_validation
      @publication.validations.find_by_user_id(params[:format]).touch
      redirect_back fallback_location: root_path,
                    notice: 'Publication was successfully revalidated.'
  end

  def publication_authors
    render partial: "authors", object: @publication.users
  end

  def publication_keywords
    render partial: 'shared/wordcloud',
           object: WordCloud.generate(40, Publication.select(:contents).where(id: params[:id]).all_content),
           locals: { title: 'publication_contents' }
  end

  private
    def set_publication
      @publication = Publication.find(params[:id])
    end

    def touch_publication
      @publication.touch
    end

    # Convert contents to utf8 format to avoid errors in forms
    def contents_convert_utf8
      @publication.title ? @publication.title = @publication.title.force_encoding('UTF-8') : @publication.title = ""
      @publication.abstract ? @publication.abstract = @publication.abstract.force_encoding('UTF-8') : @publication.abstract = ""
      @publication.contents ? @publication.contents.force_encoding('UTF-8') : @publication.contents = ""
    end

    # Depending on publication_type, empty fields that are not being used
    def empty_unused_fields
      if @publication.scientific_article?
        # Empty fields specific to categories other than scientific_article
        @publication.book_title = ''
        @publication.book_authors = ''
        @publication.book_publisher = ''
        @publication.url = ''
      else
        # Empty fields specific to scientific_article
        @publication.journal_id = 0
        @publication.new_journal_name = ''
        @publication.DOI = ''
        @publication.volume = ''
        @publication.issue = ''
        @publication.pages = ''
        unless @publication.chapter?
          # Empty fields specific to book_chapter
          @publication.book_title = ''
          @publication.book_authors = ''
        end
      end
    end

    def publication_params
      params.require(:publication).permit(
        :title,
        :authors,
        :publication_year,
        :journal_id,
        :publication_type,
        :publication_format,
        :new_journal_name,
        :volume,
        :issue,
        :pages,
        :DOI,
        :abstract,
        :contents,
        :min_depth,
        :max_depth,
        :mce,
        :tme,
        :original_data,
        :mesophotic,
        :new_species,
        :filename,
        :book_title,
        :book_publisher,
        :book_authors,
        :url,
        :pdf,
        :validations,
        :behind_contents,
        {:platform_ids => []},
        {:field_ids => []},
        {:location_ids => []},
        {:focusgroup_ids => []},
        {:user_ids => []}
      )
    end

    def search_params params
      return params if params.blank?

      # Ensure params are in the format key => [option], as checklists are
      # posted with the format key => {option => option}
      params.permit!.to_h.reduce({}) { |ps, p|
        ps.merge(p.first => p.last.try(:keys) || p.last)
      }
    end

    def is_editor_or_admin
      current_user.try(:editor_or_admin?) || false
    end
  end
