class HomeController < ApplicationController

  def index
  end

  def about
  end

  def contact
  end

  def brewtools
  end
  
  def blog
  end

  def thrive
  end

  def download
    case params[:file]
    when "Calculator"
      file_to_send = "/public/files/BJsCalculatorSetup.rar"
    end
    send_file file_to_send
  end

end
