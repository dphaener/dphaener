class BlogController < ApplicationController

	def index
		@post = Post.last(1)
  end
  
end
