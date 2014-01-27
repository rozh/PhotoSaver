# -*- coding: utf-8 -*-

class Display

  include GladeGUI

  def before_show()
    Photo.load_random_photo
    set_image
    while(Gtk.events_pending?)
      Gtk.main_iteration
    end

    @size_alloc_id = builder["image1"].signal_connect("size-allocate") { |w, x|
      builder["image1"].signal_handler_block(@size_alloc_id) {
        if ! @original.nil? then
          size = [ builder["linkbutton1"].allocation.width-10, builder["linkbutton1"].allocation.height-10]
          builder["image1"].pixbuf = get_resize_pixbuf(@original, *size)
          builder["image1"].set_padding(
            (size[0] - builder["image1"].pixbuf.width)/2,
            (size[1] - builder["image1"].pixbuf.height)/2
          )
        end

        builder["image1"].parent.check_resize()
      }
    }

    slide_show
  end

  def slide_show
    Thread.start do
      loop do
        sleep_method = Thread.start do
          sleep(10)
        end
        Photo.load_random_photo
        sleep_method.join
        set_image

        while(Gtk.events_pending?)
          Gtk.main_iteration
        end
      end
    end
  end

  def set_image
    @original = Gdk::Pixbuf.new(Photo.filename)
    size = [ builder["linkbutton1"].allocation.width-10, builder["linkbutton1"].allocation.height-10]
    pixbuf = get_resize_pixbuf(@original, *size)
    builder["image1"].pixbuf = pixbuf
    builder["image1"].set_padding(
      (size[0] - pixbuf.width)/2,
      (size[1] - pixbuf.height)/2
    )
    builder["linkbutton1"].uri = Photo.renew_url
  end

  def get_resize_pixbuf(pixbuf, w, h)
    # 画像と画面サイズの大きさで判定
    x = pixbuf.width.to_f / w.to_f
    y = pixbuf.height.to_f / h.to_f

    # より大きな縮小・拡大が必要な方を採用
    r = 1.0
    if x > y then
      r = x
    else
      r = y
    end

    if r == 0 then
      x = 0
      y = 0
    else
      x = (pixbuf.width / r).to_i
      y = (pixbuf.height / r).to_i

      if x > w then
        x = w
      elsif y > h then
        y = w
      end
    end

    return pixbuf.scale(x, y, Gdk::Pixbuf::INTERP_HYPER)
  end
end
