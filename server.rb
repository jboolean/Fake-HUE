require 'sinatra'
require 'json'
require_relative 'errors'

helpers do
	def protect!
		authorized_users = ["julianboilen"]
		if !authorized_users.include? params[:username]
			halt [(UnauthorizedUser.new).to_hash("")].to_json
			#TODO: Get the address being called somehow
		end
	end
end

get '/test/:username' do
	protect!
	"julian"
end
