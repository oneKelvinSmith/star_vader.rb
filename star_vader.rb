require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'lazer'
require_relative 'explosion'

class StarVader < Gosu::Window
  WIDTH = 800
  HEIGHT = 600
  ENEMY_FREQUENCY = 0.05

  def initialize
    super WIDTH, HEIGHT
    self.caption = 'May the force be with you...'
    @background_image = Gosu::Image.new('images/start.png')
    @scene = :start
  end

  def initialize_game
    @player      = Player.new(self)
    @enemies     = []
    @lazers      = []
    @explosions  = []
    @scene       = :game
  end

  def draw
    case @scene
    when :start
      draw_start
    when :game
      draw_game
    when :end
      draw_end
    end
  end

  def draw_start
    @background_image.draw 0, 0, 0
  end

  def draw_game
    @player.draw
    @enemies.each(&:draw)
    @lazers.each(&:draw)
    @explosions.each(&:draw)
  end

  def draw_end
  end

  def update
    case @scene
    when :game
      update_game
    when :end
      update_end
    end
  end

  def update_game
    @player.turn_left  if button_down? Gosu::KbLeft
    @player.turn_right if button_down? Gosu::KbRight
    @player.accelerate if button_down? Gosu::KbUp
    @player.move
    @enemies.push Enemy.new(self) if rand < ENEMY_FREQUENCY
    @enemies.each(&:move)
    @lazers.each(&:move)
    @enemies.dup.each do |enemy|
      @lazers.dup.each do |lazer|
        distance = Gosu.distance(enemy.x, enemy.y, lazer.x, lazer.y)
        if distance < enemy.radius + lazer.radius
          @enemies.delete enemy
          @lazers.delete lazer
          @explosions.push Explosion.new(self, enemy.x, enemy.y)
        end
      end
    end
    @enemies.dup.each do |enemy|
      @enemies.delete enemy if enemy.y > HEIGHT + enemy.radius
    end
    @explosions.dup.each do |explosion|
      @explosions.delete explosion if explosion.finished?
    end
    @lazers.dup.each do |lazer|
      @lazers.delete lazer unless lazer.onscreen?
    end
  end

  def update_end
  end

  def button_down(key)
    case @scene
    when :start
      button_down_start(key)
    when :game
      button_down_game(key)
    when :end
      button_down_end(key)
    end
  end

  def button_down_start(_key)
    initialize_game
  end

  def button_down_game(key)
    if key == Gosu::KbSpace
      @lazers.push Lazer.new(self, @player.x, @player.y, @player.angle)
    end
  end
end

window = StarVader.new
window.show
