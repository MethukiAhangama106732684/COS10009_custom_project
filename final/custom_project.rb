require 'gosu'

#RECORDS

# Colours
# Main colour palette - Dark Navy and Pastel Theme
TOP_COLOR = Gosu::Color.new(0xFF172238)
BOTTOM_COLOR = Gosu::Color.new(0xFF202F49)

PANEL_COLOR = Gosu::Color.new(0xFF293B56)
BUTTON_COLOR = Gosu::Color.new(0xFF83B9FF)
BUTTON_HOVER_COLOR = Gosu::Color.new(0xFFA8CEFF)

HEADING_COLOR = Gosu::Color.new(0xFFD2A8FF)
TEXT_COLOR = Gosu::Color.new(0xFFF5F0FF)
MUTED_COLOR = Gosu::Color.new(0xFFB9C7DF)

FOCUS_COLOR = Gosu::Color.new(0xFF83B9FF)
ENERGY_COLOR = Gosu::Color.new(0xFF9BE5B2)
STRESS_COLOR = Gosu::Color.new(0xFFFF9DAB)
PRODUCTIVITY_COLOR = Gosu::Color.new(0xFFD2A8FF)
BAR_BACKGROUND_COLOR = Gosu::Color.new(0xFF43536D)

# Screen dimensions
SCREEN_WIDTH = 700
SCREEN_HEIGHT = 650

# Modules for drawing order
module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

# Study periods
module StudyPeriod
  MORNING, AFTERNOON, EVENING = *1..3
end

# Game states
module GameState
	MENU, INSTRUCTIONS, SETUP, STUDYING, BREAK, UNPRODUCTIVE, EVENT, RESULTS, LOST = *1..9
end

STUDY_PERIOD_NAMES = ['Morning', 'Afternoon', 'Evening']

# Classes 
class PlayerStats
	attr_accessor :focus, :energy, :stress, :productivity
	def initialize(focus, energy, stress, productivity)
		@focus = focus
		@energy = energy
		@stress = stress
		@productivity = productivity
	end
end


class StudyTask
  attr_accessor :name, :duration, :progress, :completed
  def initialize(name, duration, progress, completed)
    @name = name
    @duration = duration
    @progress = progress
    @completed = completed
  end
end


class StudySession
  attr_accessor :period, :start_time, :end_time
  def initialize(period, start_time, end_time)
    @period = period
    @start_time = start_time
    @end_time = end_time
  end
end


class Activity
  attr_accessor :name, :focus_change, :energy_change, :stress_change
  def initialize(name, focus_change, energy_change, stress_change)
    @name = name
    @focus_change = focus_change
    @energy_change = energy_change
    @stress_change = stress_change
  end
end

# Stores information about random events.
class RandomEvent
  attr_accessor :title, :description, :choice_one, :choice_two, :focus_one, :energy_one, :stress_one, :progress_one, :focus_two, :energy_two, :stress_two, :progress_two, :time_one, :time_two
  def initialize(title, description, choice_one, choice_two, focus_one, energy_one, stress_one, progress_one, focus_two, energy_two, stress_two, progress_two, time_one, time_two)
    @title = title
    @description = description
    @choice_one = choice_one
    @choice_two = choice_two
    @focus_one = focus_one
    @energy_one = energy_one
    @stress_one = stress_one
    @progress_one = progress_one
    @focus_two = focus_two
    @energy_two = energy_two
    @stress_two = stress_two
    @progress_two = progress_two
    @time_one = time_one
    @time_two = time_two
  end
end


class StudyBuddyMain < Gosu::Window

  def initialize()
    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Study Buddy"

    # Fonts
    @title_font = Gosu::Font.new(35)
    @heading_font = Gosu::Font.new(25)
    @text_font = Gosu::Font.new(18)

    initialize_game()
  end

  # Set up the game
  def initialize_game()
    #setting up player stats: focus, energy, stress, productivity
    @player = PlayerStats.new(80, 90, 20, 0)

    # Create a list of study tasks
    @tasks = []
    # StudyTask: name, duration, progress, completed
    # list of study tasks (task 1,2,3 are placeholders)
    @tasks << StudyTask.new("Task 1", 180, 0, false)
    @tasks << StudyTask.new("Task 2", 180, 0, false)
    @tasks << StudyTask.new("Task 3", 180, 0, false)

    # sessions with times
    @sessions = []
    # StudySession = period, start_time, end_time
    @sessions << StudySession.new(StudyPeriod::MORNING, "9am", "12pm")
    @sessions << StudySession.new(StudyPeriod::AFTERNOON, "2pm", "5pm")
    @sessions << StudySession.new(StudyPeriod::EVENING, "7pm", "10pm")

    # activites
    @activities = []
    # Break = name, focus_change, energy_change, stress_change
    @activities << Activity.new("Take a Walk", 10, 15, -15)
    @activities << Activity.new("Drink Water", 5, 10, -5)
    @activities << Activity.new("Rest", 15, 25, -20)

    @current_task = 0 # not currently working on anything at the beginning
    @completed_tasks = 0 # counts how many tasks the player has finished. - no completed tasks yet 
    @score = 0 # stores the final performance score - no score yet
    @game_state = GameState::MENU # current screen type
    @message = "Welcome to StudyBuddy" # Stores messages displayed to the player.
    @breaks_remaining = 3
    @current_event = nil
    @event_times = nil
    @session_events = nil
    @events_triggered_this_session = 0

    # Create random events.
    # RandomEvent = title, description, choice one, choice two, focus of choice one, energy of choice one, stress of choice one, progress of choice one, focus of choice two, energy of choice two, stress of choice two,  progress of choice two
    @random_events = [] 
    @random_events << RandomEvent.new("YOUR FRIEND TEXTS!", "Your friend texts you multiple times", "Call them", "Ignore them", -15, -10, -15, -10, 5, 5, 20, 0, 45, 0)
    @random_events << RandomEvent.new("YOUR DOG ATE YOUR HOMEWORK!", "Your dog has destroyed half of your assignment!", "Rewrite the entire section", "Submit the damaged assignment", -20, -25, 20, -15, -10, 0, 25, -25, 90, 0)
    @random_events << RandomEvent.new("YOUR PHONE IS RINGING!", "Your phone will not stop ringing.\n It is an important call!", "Answer and have a long conversation", "Silence your phone and ignore it", -15, -15, -10, -10, 5, 0, 15, 0, 60, 0)
    @random_events << RandomEvent.new("YOU ARE STUCK!", "You have spent an hour on one question and still cannot solve it. \n Your deadline is getting dangerously close!", "Ask your friend for urgent help", "Keep trying on your own", 15, -20, -10, 15, -20, -25, 20, -15, 45, 60)
    @random_events << RandomEvent.new("FRIENDS INVITE YOU OUT!", "Your friends are going out. They insist this \n is your last chance to join them before everyone gets busy!", "Go out with them", "Stay home and finish your work", -5, 20, -30, -30, -15, -20, 25, 15, 60, 0)
    @random_events << RandomEvent.new("POWER OUTAGE!", "A massive storm knocks out the electricity. Your laptop \n battery is almost dead and your assignment has not been saved!", "Use your phone hotspot and keep working", "Stop and wait for the electricity", -20, -20, 25, -15, -10, 5, 15, -10, 45, 30)
    @random_events << RandomEvent.new("UNEXPECTED HOMEWORK!", "Your teacher has just uploaded a surprise assignment due \n tomorrow morning. It is worth 40% of your grade!", "Start the surprise assignment immediately", "Ignore it and finish your current task", -25, -30, 25, -20, 10, -15, 20, 15, 120, 0)      
    @random_events << RandomEvent.new("A DISTRACTING NOTIFICATION!", "You get a no called id call. Your phone keeps buzzing!", "Answer the phone in case it is an emergency", "Block the notifications and keep studying", -20, -15, 20, -15, 5, 0, -5, 5, 60, 0)  
    @random_events << RandomEvent.new("YOU FEEL UNWELL!", "You develop a terrible headache and feel completely exhausted. \nYou are struggling to concentrate on even the simplest questions!", "Stop and take time to recover", "Push through and finish your work", 10, 20, -20, -15, -25, -30, 30, 10, 60, 0)
    @random_events << RandomEvent.new("A BURST OF MOTIVATION!", "You suddenly feel unstoppable! You have enough \n motivation to finisha huge amount of work, \n but you risk completely exhausting yourself!", "Work intensely while motivation lasts", "Slow down and plan carefully", -10, -25, 15, 30, 10, 5, -10, 5, 60, 20)

    @planned_tasks = ["", "", ""] # filled based on user input
    @setup_index = 0 # to input tasks for correct sessions i.e. session 0, task 0
    @task_input = nil # no input yet
    @game_hour = 9 # Stores the current game hour
    @game_minute = 0 # Stores the current game minute
    @last_update_time = Gosu.milliseconds # Remembers when the last update happened
    @time_counter = 0 # Tracks real milliseconds towards the next game-time update
    @study_elapsed_minutes = 0 # Tracks how long the player has studied on the current task
    @study_active = false # Checks whether the player has started studying
    # Break timer
    @break_elapsed_minutes = 0
    @break_active = false
  end

  def formatted_game_time()
    display_hour = @game_hour % 12
    if display_hour == 0
      display_hour = 12 
    end
  
    time_text = "#{display_hour}:#{@game_minute.to_s.rjust(2, '0')}"
  
    if @game_hour < 12
      time_text += " AM"
    else
      time_text += " PM"
    end
  
    return time_text
  end

  # Shows the welcome message and start button.
  def display_menu()
    @title_font.draw_text("STUDY BUDDY", 200, 130, ZOrder::UI, 1, 1, TEXT_COLOR)
    @heading_font.draw_text("Your personal study day simulator", 125, 210, ZOrder::UI, 1, 1, TEXT_COLOR)
    draw_button(250, 320 ,200 ,60, "START STUDY DAY")
    @text_font.draw_text("Click the button to begin!", 240, 410, ZOrder::UI, 1, 1, TEXT_COLOR)
  end

  # Explains the rules of the game.
  def display_instructions()
    @heading_font.draw_text("HOW TO PLAY", 250, 85, ZOrder::UI, 1, 1, HEADING_COLOR)
    instructions = [
      "1. Enter three tasks for your study sessions.",
      "2. Click STUDY to start working.",
      "3. Focus and energy decrease as you study.",
      "4. Stress increases as you study.",
      "5. Breaks allow to manage focus, evenry and stress levels",
      "6. Take breaks to stay productive ",
      "7. You have only 20 min break per for the day.",
      "8. Random events occur during each study session.",
      "9. Complete all tasks to achieve a high score.",
      "10. Run out of breaks when unproductive and it's GAME OVER!"
    ]

    y_position = 150
    # for every instruciton in instructions print 38 pixels below the last one
    instructions.each do |instruction| 
      @text_font.draw_text(instruction, 65, y_position, ZOrder::UI, 1, 1, TEXT_COLOR)
      y_position += 38
    end
    draw_button(250, 550, 200, 55, "CONTINUE")
  end

  # Allows the player to enter a task for each study session.
  def display_setup()
    @heading_font.draw_text("CREATE YOUR TO-DO LIST", 170, 100, ZOrder::UI, 1, 1, TEXT_COLOR)
    session_names = ["Morning", "Afternoon", "Evening"]
    @text_font.draw_text("Enter your task for the #{session_names[@setup_index]} session:", 100, 200, ZOrder::UI, 1, 1, TEXT_COLOR)

    # Draw the text input area.
    draw_rect(100, 260, 500, 60, TEXT_COLOR, ZOrder::PLAYER)
    @text_font.draw_text(@task_input.text, 115, 280, ZOrder::UI, 1, 1, Gosu::Color::BLACK)
    @text_font.draw_text("Type your task and press ENTER.", 150, 370, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Session #{@setup_index + 1} of 3", 280, 430, ZOrder::UI, 1, 1, HEADING_COLOR)
  end


  # Displays the study screen
  def display_study()
    # Morning study information at the top left.
    session = @sessions[@current_task]
    task = @tasks[@current_task]

    @heading_font.draw_text("#{STUDY_PERIOD_NAMES[@current_task]} STUDY", 30, 100, ZOrder::UI, 1, 1, HEADING_COLOR) # displays e.g. MORNING STUDY
    @text_font.draw_text("Session: #{session.start_time} - #{session.end_time}", 30, 145, ZOrder::UI, 1, 1, TEXT_COLOR) # desplays e.g. 9-12
    @text_font.draw_text("Current Time: #{formatted_game_time()}", 30, 185, ZOrder::UI, 1, 1, TEXT_COLOR) # current game time
    @text_font.draw_text("Current Task: #{task.name}", 30, 225, ZOrder::UI, 1, 1, TEXT_COLOR) 

    # Study progress + bar
    @text_font.draw_text("Study Progress: #{task.progress}%", 380, 245, ZOrder::UI, 1, 1, TEXT_COLOR)
    draw_progress_bar(380, 280, task.progress)

    # Player statistics with coloured progress bars.
    @heading_font.draw_text("PLAYER STATISTICS", 380, 340, ZOrder::UI, 1, 1, HEADING_COLOR)
    # x, y, name, value, colour
    draw_stat_bar(380, 380, "Focus", @player.focus, FOCUS_COLOR)
    draw_stat_bar(380, 435, "Energy", @player.energy, ENERGY_COLOR)
    draw_stat_bar(380, 490, "Stress", @player.stress, STRESS_COLOR)
    draw_stat_bar(380, 545, "Productivity", @player.productivity, PRODUCTIVITY_COLOR)

    # study and break buttons at the bottom left.
    draw_button(30, 340, 220, 55, "STUDY")
    draw_button(30, 410, 220, 55, "TAKE A BREAK")
    @text_font.draw_text(@message, 30, 610, ZOrder::UI, 1, 1, TEXT_COLOR)
  end

  # Shows break activities and the player's current statistics.
  def display_break()
    # Display player statistics on the left.
    @heading_font.draw_text("PLAYER STATISTICS", 30, 100, ZOrder::UI, 1, 1, HEADING_COLOR)
    draw_stat_bar(30, 160, "Focus", @player.focus, FOCUS_COLOR)
    draw_stat_bar(30, 220, "Energy", @player.energy, ENERGY_COLOR)
    draw_stat_bar(30, 280, "Stress", @player.stress, STRESS_COLOR)
    draw_stat_bar(30, 340, "Productivity", @player.productivity, PRODUCTIVITY_COLOR)

    # Display break activities on the right.
    @heading_font.draw_text("TIME FOR A BREAK!", 350, 100, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Choose an activity:", 350, 170, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Breaks remaining: #{@breaks_remaining}", 350, 200, ZOrder::UI, 1, 1, TEXT_COLOR)

    # if not already having a break, choose one
    if @break_active == false
      draw_button(350, 230, 230, 50, "1. GO FOR A WALK")
      draw_button(350, 300, 230, 50, "2. DRINK WATER")
      draw_button(350, 370, 230, 50, "3. REST")
    else
      remaining_time = 15 - @break_elapsed_minutes # time left on break
      @heading_font.draw_text("BREAK IN PROGRESS", 350, 250, ZOrder::UI, 1, 1, Gosu::Color::GREEN)
      @text_font.draw_text("Time remaining: #{remaining_time} minutes", 350, 310, ZOrder::UI, 1, 1, TEXT_COLOR)
    end

    # Display messages at the bottom.
    @text_font.draw_text(@message, 30, 580, ZOrder::UI, 1, 1, TEXT_COLOR)
  end

  # Displays the game over screen.
  def display_lost()
    @title_font.draw_text("GAME OVER!", 240, 130, ZOrder::UI, 1, 1, Gosu::Color::RED)
    @heading_font.draw_text("You have run out of energy!", 150, 230, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("You have no breaks left and you cannot continue studying without a break.", 100, 300, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Your final score: #{@score}", 230, 370, ZOrder::UI, 1, 1, HEADING_COLOR)
    draw_button(250, 450, 200, 60, "PLAY AGAIN")
  end

  def display_unproductive()
    @title_font.draw_text("TOO EXHAUSTED!", 210, 70, ZOrder::UI, 1, 1, STRESS_COLOR)

    # Display current stats
    @heading_font.draw_text("Your Player Stats", 240, 140, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Focus: #{@player.focus}/100", 220, 190, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Energy: #{@player.energy}/100", 220, 225, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Stress: #{@player.stress}/100", 220, 260, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Productivity: #{@player.productivity}/100", 220, 295, ZOrder::UI, 1, 1, TEXT_COLOR)
  
    # Descirbes why unproductive
    y_position = 350
    if @player.focus < 30
      @text_font.draw_text("Your focus is too low!", 180, y_position, ZOrder::UI, 1, 1, STRESS_COLOR)
      y_position += 30
    end
    if @player.energy < 30
      @text_font.draw_text("Your energy is too low!", 180, y_position, ZOrder::UI, 1, 1, STRESS_COLOR)
      y_position += 30
    end
    if @player.stress >= 85
      @text_font.draw_text("Your stress is too high!", 180, y_position, ZOrder::UI, 1, 1, STRESS_COLOR)
      y_position += 30
    end
  
    @text_font.draw_text("Breaks remaining: #{@breaks_remaining}", 220, y_position + 10, ZOrder::UI, 1, 1, TEXT_COLOR)
  
    draw_button(250, 500, 200, 60, "TAKE A BREAK")
  end

  # Displays a random event and its choices.
  def display_event()
    display_stats()
    @heading_font.draw_text(@current_event.title, 250, 120, ZOrder::UI, 1, 1, HEADING_COLOR)
    @text_font.draw_text(@current_event.description, 240, 150, ZOrder::UI, 1, 1, TEXT_COLOR)
    draw_button(150, 320, 400, 55, @current_event.choice_one)
    draw_button(150, 410, 400, 55, @current_event.choice_two)
    @text_font.draw_text("Choose carefully! Your statistics will change.", 100, 510, ZOrder::UI, 1, 1, TEXT_COLOR)
  end

  # Displays focus, energy, stress and productivity.
  def display_stats()
    @heading_font.draw_text("PLAYER STATISTICS", 30, 100, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Focus: #{@player.focus}/100", 30, 160, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Energy: #{@player.energy}/100", 30, 200, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Stress: #{@player.stress}/100", 30, 240, ZOrder::UI, 1, 1, TEXT_COLOR)
    @text_font.draw_text("Productivity: #{@player.productivity}/100", 30, 280, ZOrder::UI, 1, 1, TEXT_COLOR)
  end

  # Shows the final results and score.
  def display_results()
      @title_font.draw_text("STUDY DAY COMPLETE!", 150, 100, ZOrder::UI, 1, 1, TEXT_COLOR)
      @heading_font.draw_text("FINAL RESULTS!", 250, 190, ZOrder::UI, 1, 1, TEXT_COLOR)
      @text_font.draw_text("Tasks Completed: #{@completed_tasks}/3", 220, 250, ZOrder::UI, 1, 1, TEXT_COLOR)
      @text_font.draw_text("Final Focus: #{@player.focus}", 220, 290, ZOrder::UI, 1, 1, TEXT_COLOR)
      @text_font.draw_text("Final Energy: #{@player.energy}", 220, 325, ZOrder::UI, 1, 1, TEXT_COLOR)
      @text_font.draw_text("Final Stress: #{@player.stress}", 220, 360, ZOrder::UI, 1, 1, TEXT_COLOR) 
      @text_font.draw_text("Performance Score: #{@score}/100", 170, 430, ZOrder::UI, 1, 1, HEADING_COLOR)
      draw_button(250, 530, 200, 55, "PLAY AGAIN")
  end

  def draw_progress_bar(x, y, progress)
      draw_rect(x, y, 200, 20, TEXT_COLOR, ZOrder::UI) # full progress bar
      draw_rect(x, y, progress * 2, 20, Gosu::Color::GREEN, ZOrder::UI) # actual progress
  end

  # Draws a coloured progress bar for player statistics.
  def draw_stat_bar(x, y, label, value, bar_colour)
    value = [[value, 0].max, 100].min
    bar_width = 240
    bar_height = 14
    @text_font.draw_text("#{label}: #{value}/100", x, y, ZOrder::UI, 1, 1, TEXT_COLOR)
    # Background of the progress bar.
    Gosu.draw_rect( x, y + 25, bar_width, bar_height, BAR_BACKGROUND_COLOR, ZOrder::UI)
    # Filled section of the progress bar.
    fill_width = (bar_width * value / 100.0).to_i
    Gosu.draw_rect(x, y + 25, fill_width, bar_height, bar_colour, ZOrder::UI)
  end

  # Draws buttons with a hover effect.
  def draw_button(x, y, width, height, text)
    # Check whether the mouse is hovering over the button.
    if mouse_x >= x && mouse_x <= x + width && mouse_y >= y && mouse_y <= y + height
      button_colour = BUTTON_HOVER_COLOR
    else
      button_colour = BUTTON_COLOR
    end
    # Draw the button.
    draw_rect(x, y, width, height, button_colour, ZOrder::PLAYER)
    # Draw the button text.
    @text_font.draw_text(text, x + 15, y + 15, ZOrder::UI, 1, 1, TOP_COLOR)
  end

  def draw_background()
      draw_quad(0, 0, TOP_COLOR, SCREEN_WIDTH, 0, TOP_COLOR, SCREEN_WIDTH, SCREEN_HEIGHT, BOTTOM_COLOR, 0, SCREEN_HEIGHT, BOTTOM_COLOR, ZOrder::BACKGROUND)
  end

  # Updates the game clock and study or break progress
  def update()
    current_time = Gosu.milliseconds 
    elapsed_time = current_time - @last_update_time
    @last_update_time = current_time

    if (@game_state == GameState::STUDYING && @study_active) || (@game_state == GameState::BREAK && @break_active) # if player is studying or on break
      @time_counter += elapsed_time
      while @time_counter >= 1000
        @game_minute += 10
        @time_counter -= 1000
        if @game_minute >= 60
          @game_hour += 1
          @game_minute -= 60
        end

        if @game_state == GameState::STUDYING && @study_active
          @study_elapsed_minutes += 10
          # Update player statistics as study time passes.
          @player.focus -= 1
          @player.energy -= 1
          @player.stress += 1
          @player.productivity += 1

          # Keep statistics between 0 and 100.
          clamp_stats()
          @player.productivity = [[@player.productivity, 0].max, 100].min
          check_productivity()
          if @game_state != GameState::STUDYING
            return
          end

          task = @tasks[@current_task]

          task.progress = (@study_elapsed_minutes.to_f / task.duration * 100).to_i # calculates how much of the current task has been completed as a percentage

          # random event time
          if @events_triggered_this_session < 2 && @study_elapsed_minutes >= @event_times[@events_triggered_this_session]
            @study_active = false
            @current_event = @session_events[@events_triggered_this_session]
            @events_triggered_this_session += 1
            @game_state = GameState::EVENT
            @message = "An unexpected event occurred!"
          end

          if task.progress >= 100
            task.progress = 100
            @study_active = false
            complete_study_task()
          end

        elsif @game_state == GameState::BREAK && @break_active
          @break_elapsed_minutes += 5
          if @break_elapsed_minutes >= 15
            @break_active = false
            @game_state = GameState::STUDYING
            @message = "Break finished! Time to study."
            check_productivity()
          end
        end
      end
    end
  end

  def draw()
    draw_background()
    @title_font.draw_text("STUDY BUDDY", 240, 25, ZOrder::UI, 1, 1, HEADING_COLOR)
    case @game_state
    when GameState::MENU
      display_menu()
    when GameState::INSTRUCTIONS
      display_instructions()
    when GameState::SETUP
      display_setup()
    when GameState::STUDYING
      display_study()
    when GameState::BREAK
      display_break()
    when GameState::UNPRODUCTIVE
      display_unproductive()
    when GameState::EVENT
      display_event()
    when GameState::RESULTS
      display_results()
    when GameState::LOST
      display_lost()
    end
  end

  # Starts the to-do list setup.
  def start_setup()
    @planned_tasks = ["", "", ""]
    @setup_index = 0
    @task_input = Gosu::TextInput.new
    self.text_input = @task_input
    @game_state = GameState::SETUP
    @message = "Enter your study tasks."
  end

  # Saves each task entered by the player.
  def save_planned_task()
    task_name = @task_input.text.strip
    if task_name.empty?
      @message = "Please enter a task before continuing."
      return
    end
    @planned_tasks[@setup_index] = task_name
    if @setup_index < 2
      @setup_index += 1
      @task_input.text = ""
    else
      # Apply the entered names to the study tasks.
      @tasks[0].name = @planned_tasks[0]
      @tasks[1].name = @planned_tasks[1]
      @tasks[2].name = @planned_tasks[2]
      self.text_input = nil
      @task_input = nil
      @game_state = GameState::STUDYING
      @message = "Your study day has started!"
    end
  end

  def clamp_stats()
    @player.focus = [[@player.focus, 0].max, 100].min
    @player.energy = [[@player.energy, 0].max, 100].min
    @player.stress = [[@player.stress, 0].max, 100].min
  end

  # Applies the effects of the player's event choice.
    def choose_event(choice)
      if @current_event.nil?
        return 
      end
      task = @tasks[@current_task]
    
      if choice == 1
        @player.focus += @current_event.focus_one
        @player.energy += @current_event.energy_one
        @player.stress += @current_event.stress_one
        task.progress += @current_event.progress_one
        @game_minute += @current_event.time_one
      else
        @player.focus += @current_event.focus_two
        @player.energy += @current_event.energy_two
        @player.stress += @current_event.stress_two
        task.progress += @current_event.progress_two
        @game_minute += @current_event.time_two
      end

      while @game_minute >= 60
        @game_hour += 1
        @game_minute -= 60
      end

      if @current_event.title == "FRIENDS INVITE YOU OUT!" && choice == 1
        @game_hour = 22
        @game_minute = 0
        @current_event = nil
        @study_active = false
        calculate_score()
        @game_state = GameState::RESULTS
        @message = "You went out with your friends! You are no longer \n focused or energetic enough to study. \n Your study day is over. Try again tomorrow."
        return
      end
    
      # Keep assignment progress between 0 and 100.
      task.progress = [[task.progress, 0].max, 100].min
    
      # Synchronise the study timer with the updated progress.
      @study_elapsed_minutes = (task.progress * task.duration / 100.0).ceil # ceil = .round up
      if @events_triggered_this_session == 1
        @event_times[1] = @study_elapsed_minutes + rand(60..90)
      end
    
      # Keep statistics between 0 and 100.
      clamp_stats()
    
      @message = "You responded to the event!"
    
      # Clear the event.
      @current_event = nil
    
      # Return to the SAME study session.
      @game_state = GameState::STUDYING
    
      # If the event completed the assignment, complete the task.
      if task.progress >= 100
        task.progress = 100
        @study_elapsed_minutes = task.duration
        complete_study_task()
      else
        @study_active = true
      end
    
      check_productivity()
    end

  # Starts studying the current task
  def start_study()
    if @study_active == false
      if @session_events.nil?
        @session_events = @random_events.sample(2)
        @event_times = [rand(30..60), rand(120..150)]
        @events_triggered_this_session = 0
      end
      @study_active = true
      @message = "You started studying!"
    end
  end

  def complete_study_task()
    task = @tasks[@current_task]
    task.progress = 100
    @player.focus -= rand(10..18)
    @player.energy -= rand(12..20)
    @player.stress += rand(10..18)
    @player.productivity += 20
    if task.progress >= 100
      task.progress = 100
      task.completed = true
      @completed_tasks += 1
      @message = "#{task.name} completed!"
      advance_schedule()
    else
      @message = "Good work! Keep studying."
    end
    check_productivity()
  end

  # Applies the effects of a break activity
  def perform_activity(number)
    activity = @activities[number]
    @player.focus += activity.focus_change
    @player.energy += activity.energy_change
    @player.stress += activity.stress_change
    # Keep player statistics between 0 and 100
    clamp_stats()

    @message = "You chose #{activity.name}!"

    # Start the 15-minute break
    @break_elapsed_minutes = 0
    @break_active = true
    @time_counter = 0

    @breaks_remaining -= 1
  end

  def check_productivity()
    if @player.energy < 30 ||
       @player.focus < 30 ||
       @player.stress >= 85
  
      if @game_state != GameState::RESULTS &&
         @game_state != GameState::EVENT
  
        @study_active = false
  
        if @breaks_remaining <= 0
          @game_state = GameState::LOST
          calculate_score()
          @message = "You have run out of breaks!"
        else
          @game_state = GameState::UNPRODUCTIVE
          @message = "Your stress is too high! You need a break!"
        end
      end
    end
  end

  # Restores the player's statistics during lunch and dinner.
  def recover_during_meal()
    # Restore focus and energy significantly.
    @player.focus += 25
    @player.energy += 30
    # Reduce stress slightly.
    @player.stress -= 25
    # Keep statistics between 0 and 100.
    clamp_stats()
  end

  def advance_schedule()
    @current_task += 1
    # Reset the study timer for the next task.
    @study_elapsed_minutes = 0
    @study_active = false
    @time_counter = 0
    @event_times = nil
    @session_events = nil
    @events_triggered_this_session = 0

    if @current_task >= @tasks.length
      # End the study day at 10 PM.
      @game_hour = 22
      @game_minute = 0
      calculate_score()
      @game_state = GameState::RESULTS
    else
      # Move to the next scheduled study session.
      if @current_task == 1
        @game_hour = 14
        @game_minute = 0
        recover_during_meal()
        @message = "Lunch is over! Your energy and focus have recovered!"
      elsif @current_task == 2
        @game_hour = 19
        @game_minute = 0
        recover_during_meal()
        @message = "Dinner is over! Your energy and focus have recovered!"
      end
      @game_state = GameState::STUDYING
    end
  end

  def calculate_score()
    stats_score = (@player.focus + @player.energy + (100 - @player.stress)) / 3
    task_score = (@completed_tasks.to_f / @tasks.length) * 100
    penalty = (@tasks.length - @completed_tasks) * 10
    @score = [(stats_score * 0.6 + task_score * 0.4 - penalty).to_i,0].max
  end

  def area_clicked(leftX, topY, rightX, bottomY)
    if mouse_x >= leftX && mouse_x <= rightX && mouse_y >= topY && mouse_y <= bottomY
      return true
    else
      return false
    end
  end

  def needs_cursor?()
      true
  end

  def button_down(id)
    if id == Gosu::KB_RETURN && @game_state == GameState::SETUP
      save_planned_task()
      return
    end
  
    case id
    when Gosu::MsLeft
      if @game_state == GameState::MENU
        if area_clicked(250, 320, 450, 380)
          @game_state = GameState::INSTRUCTIONS
        end
  
      elsif @game_state == GameState::INSTRUCTIONS
        if area_clicked(250, 550, 450, 605)
          start_setup()
        end
  
      elsif @game_state == GameState::STUDYING
        # Study button
        if area_clicked(30, 340, 250, 395)
          start_study()
      
        # Take a break
        elsif area_clicked(30, 410, 250, 465)
          @study_active = false
          start_break()
        end
        
      elsif @game_state == GameState::BREAK
        if @break_active == false
          if area_clicked(350, 230, 580, 280)
            perform_activity(0)
          elsif area_clicked(350, 300, 580, 350)
            perform_activity(1)
          elsif area_clicked(350, 370, 580, 420)
            perform_activity(2)
          end
        end
  
      elsif @game_state == GameState::UNPRODUCTIVE
      if area_clicked(250, 500, 450, 560)
        start_break()
      end
  
      elsif @game_state == GameState::EVENT
        if area_clicked(150, 320, 550, 375)
          choose_event(1)
        elsif area_clicked(150, 410, 550, 465)
          choose_event(2)
        end
  
      elsif @game_state == GameState::RESULTS
        if area_clicked(250, 530, 450, 585)
          initialize_game()
        end
  
      elsif @game_state == GameState::LOST
        if area_clicked(250, 450, 450, 510)
          initialize_game()
        end
      end
    end
  
    if id == Gosu::KB_ESCAPE
      close()
    end
  end

  # Opens the break activity screen
  def start_break()
    if @breaks_remaining > 0
      @break_active = false
      @break_elapsed_minutes = 0
      @game_state = GameState::BREAK
    else
      @message = "No breaks remaining!"
    end
  end

end

    
StudyBuddyMain.new().show() if __FILE__ == $0














