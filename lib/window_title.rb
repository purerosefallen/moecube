require_relative 'window_list'
class Window_Title < Window_List
  Button_Count = 5
  WLH = 50
  attr_reader :x, :y, :width, :height, :single_height, :index
  def initialize(x,y)
    @button = Surface.load "graphics/system/titlebuttons.png"
    @button.set_alpha(RLEACCEL,255)
    @single_height = @button.h / Button_Count
    super(x,y,@button.w / 3,WLH * Button_Count - (WLH - @button.h / Button_Count))
    @cursor_se = Mixer::Wave.load 'audio/se/cursor.ogg'
    @item_max = 6
    refresh
  end
  def index=(index)
    if index and @index != index
      Mixer.play_channel(-1,@cursor_se,0)
    end
    super
  end
  def mousemoved(x,y)
    self.index = (y - @y) / WLH
  end
  def draw_item(index, status=0)
    Surface.blit(@button, @width*status, @single_height*index, @width, @single_height, @contents, 0, WLH*index)
  end
  def clicked
    $scene.determine
  end
  def clear(x=0,y=0,width=@width,height=@height)
    @contents.fill_rect(x,y,width, height, 0x00000000)
  end
end