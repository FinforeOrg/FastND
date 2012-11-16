class FinanceController < ApplicationController

  def info
    tickers = open("http://www.google.com/finance/info?infotype=infoquoteall&q=#{params[:q]}").read.
              gsub(/\n|^\/\/\s/,"").gsub(/\s\:\s/, "=>").gsub(/\"\:/,"\"=>")
    render :json => eval(tickers).to_json, :callback => params[:callback]
  end

end
