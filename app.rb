# encoding: utf-8
require 'sinatra'
require 'sinatra/activerecord'
require 'slim'
require 'alphadecimal'

set :database, 'sqlite3:///db/development.sqlite3'

class ShortenedUrl < ActiveRecord::Base
	validates_uniqueness_of :url
	validates_presence_of :url
	validates_format_of :url, :with => /^\b((?:https?:\/\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))$/

	def shorten
		self.id.alphadecimal
	end

	def self.find_by_shortened(shortened)
    	find(shortened.alphadecimal)
  	end
end

get '/' do
	slim :index
end

post '/' do
	@shortened_url = ShortenedUrl.find_or_create_by_url params[:url]
	if @shortened_url.valid?
		slim :success
	else
		slim :index
	end
end

get '/:shortened' do
    short_url = ShortenedUrl.find_by_shortened(params[:shortened])
    redirect short_url.url
end