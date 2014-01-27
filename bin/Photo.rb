# -*- coding: utf-8 -*-
require 'mechanize'


class Photo
  RAM_PATH = ENV["HOME"] +"/ramdisk"
  SAVE_PATH = ENV["HOME"] +"/ramdisk/hogehoge.jpg"
  MIN_STAR = 3

  def self.load_random_photo
    i = 0
    until agent = rand_photo
      i += 1
    end
    p i
    src = agent.page.search(".//img[@id='image']").at('img')['src']

    name = filename
    if File.exist?(name)
      File.delete(name)
    end
    agent.get(src).save_as(name)
    return src
  end

  def self.filename
    if ramdisk_exist?
      return SAVE_PATH
    else
      return "./hogehoge.jpg"
    end
  end

  def self.ramdisk_exist?()
    if File.exists?(RAM_PATH)
      return true
    else
      return false
    end
  end

  def self.rand_photo
    @@prng = Random.rand(10000000)
    url = "http://www.photohito.com/photo/orgshow/"+ @@prng.to_s
    agent = Mechanize.new
    begin
      agent.get(url)
      if star_ok?()
        return agent
      else
        return false
      end
    rescue Mechanize::ResponseCodeError
      return false
    end
  end

  def self.star_ok?()
    agent = Mechanize.new
    begin
      agent.get(renew_url)
      star = agent.page.search(".//p[@class='like']").children.inner_text.to_i
      if star >= MIN_STAR
        return true
      else
        return false
      end
    rescue Mechanize::ResponseCodeError
      return false
    end
  end

  def self.renew_url()
    return "http://www.photohito.com/photo/"+ @@prng.to_s
  end
end

if $0 == __FILE__
  p Photo.load_random_photo
end
