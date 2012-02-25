class IocController < ApplicationController
	skip_before_filter :login_required

	def search
		@ioc_search = IocSearch.new(:term => params[:term])
		return unless @ioc_search.valid?

		@results = @ioc_search.search_all
	end

	def index
		@orders = Order.find(:all, :order => 'orders.sort_order')
	end

	def order
		begin
			@order = Order.find_by_latin_name(params[:order])
			@families = @order.families
		rescue
			flash[:warning] = UNKNOWN_TAXON_ERROR
			redirect_to :controller => 'ioc', :action => :index
		end
	end

	def family
		# From here on out, we have to worry about the family "incertae sedis" existing more than once
		begin
			@families = Family.find(:all, :conditions => ['orders.latin_name = ? AND families.latin_name = ?', params[:order], params[:family]], :joins => 'LEFT OUTER JOIN orders ON families.order_id = orders.id', :order => 'families.sort_order')

			@order = @families.first.order
			@family = @families.first # For labeling and breadcrumb purposes, any one of these will do
		rescue
			logger.debug $!
			flash[:warning] = UNKNOWN_TAXON_ERROR
			redirect_to :controller => 'ioc', :action => :order, :order => params[:order]
		end
	end

	def genus
		begin
			@species = Species.find(:all, :conditions => ['orders.latin_name = ? AND families.latin_name = ? AND genera.latin_name = ? AND species.change_id IS NULL', params[:order], params[:family], params[:genus]], :joins => 'LEFT OUTER JOIN genera ON species.genus_id = genera.id LEFT OUTER JOIN families ON genera.family_id = families.id LEFT OUTER JOIN orders on families.order_id = orders.id', :order => 'species.sort_order')

			@genus = @species.first.genus
			@family = @genus.family
			@order = @family.order
		rescue
			flash[:warning] = UNKNOWN_TAXON_ERROR
			redirect_to :controller => 'ioc', :action => :family, :order => params[:order], :family => params[:family]
		end
	end

	def species
		begin
			@species = Species.find(:first, :conditions => ['orders.latin_name = ? AND families.latin_name = ? AND genera.latin_name = ? AND species.latin_name = ? AND change_id IS NULL', params[:order], params[:family], params[:genus], params[:species]], :joins => 'LEFT OUTER JOIN genera ON species.genus_id = genera.id LEFT OUTER JOIN families ON genera.family_id = families.id LEFT OUTER JOIN orders on families.order_id = orders.id')
			@species.latin_name # Will trigger an exception if needed

			@genus = @species.genus
			@family = @genus.family
			@order = @family.order
		rescue
			flash[:warning] = UNKNOWN_TAXON_ERROR
			redirect_to :controller => 'ioc', :action => :genus, :order => params[:order], :family => params[:family], :genus => params[:genus]
		end
	end

        def paginate_species_photos
          species = Species.find_by_id(params[:id])
          
          respond_to do |format|
            format.html do
              render :partial => 'paginate_species_photos', :layout => true, :locals => {:species => species}
            end
            format.js do
              render :update do |page|
                page.replace_html 'sighting-photos', :partial => 'paginate_species_photos', :locals => {:species => species}
              end
            end
          end
        end

	def alternate_name
		@alternate_names = AlternateName.find_all_valid_by_exact_name(params[:name])

		unless @alternate_names.size > 0
			redirect_to :controller => 'ioc', :action => 'index'
			return
		end

		render :template => 'sighting/alternate_name'
	end
end
