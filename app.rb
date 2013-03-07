# encoding: utf-8
require 'sinatra'
# require 'sinatra/activerecord'
require 'slim'
# require 'alphadecimal'
require 'redis'

#set :database, 'sqlite3:///db/development.sqlite3'

# class ShortenedUrl < ActiveRecord::Base
# 	validates_uniqueness_of :url
# 	validates_presence_of :url
# 	validates_format_of :url, :with => /^\b((?:https?:\/\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))$/

# 	def shorten
# 		self.id.alphadecimal
# 	end

# 	def self.find_by_shortened(shortened)
#     	find(shortened.alphadecimal)
#   	end
# end

helpers do
	def shortlink_token
		(Time.now.to_i + rand(36**8)).to_s(36)
	end
end

get '/' do
	slim :index
end

post '/' do
	@redis = Redis.new(host: 'localhost', port: 6379, password: nil)
	unless (params[:url] =~ URI::regexp).nil?
		@token = shortlink_token
		@redis.set "links:#{@token}", params[:url]
		slim :success
	else
		@error = "Please enter a valid URL"
		slim :index
	end
	# @shortened_url = ShortenedUrl.find_or_create_by_url params[:url]
	# if @shortened_url.valid?
	# 	slim :success
	# else
	# 	slim :index
	# end
end

get '/:token/?' do
	@redis = Redis.new(host: 'localhost', port: 6379, password: nil)
    url = @redis.get "links:#{params[:token]}"
    redirect url unless url.nil?
    slim :expired
end