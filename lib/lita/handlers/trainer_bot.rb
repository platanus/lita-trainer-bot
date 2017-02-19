require 'rufus-scheduler'
require 'date'

module Lita
  module Handlers
    class TrainerBot < Handler
      on :loaded, :load_on_start
      def load_on_start(_payload)
        create_schedule
      end

      route(/hazme una pregunta de finanzas/i, command: true) do
        refresh
      end

      route(/en qué pregunta vamos\?/i, command: true) do |response|
        response.reply("Vamos en la número #{redis.get('current_trainer_question')}")
      end

      route(/muévete a la pregunta ([\d]+)/i, command: true) do |response|
        redis.set('current_trainer_question', response.matches[0][0])
        response.reply("Ok, entonces vamos en la número #{redis.get('current_trainer_question')}")
      end

      route(/dime la respuesta porfa/i, command: true) do |response|
        response.reply("La respuesta correcta es la #{answer(current_question)}")
      end

      route(/es la ([a-d]+)\?/i, command: true) do |response|
        if check(current_question, response.matches[0][0])
          response.reply("Sí! la #{response.matches[0][0]}!")
        else
          response.reply("No compadre.")
        end
      end

      def post_question(n)
        message = spreadsheet.read_row(n, 1).to_s
        message += "\n"
        4.times do |d|
          message += "#{(d + 97).chr}) #{spreadsheet.read_row(n, d + 2)}"
          message += "\n"
        end
        robot.send_message(Source.new(room: "#fintual-industria"), message)
      end

      def answer(n)
        spreadsheet.read_row(n, 6).to_s
      end

      def check(question, guess)
        answer(question) == guess
      end

      def spreadsheet
        @sp ||= Services::SpreadsheetService.new("1xeU8acXFj5i7f9Nog-c1zcx7kcWKAIoiHIDprw2WP_U")
      end

      def refresh
        redis.set('current_trainer_question', current_question + 1)
        post_question(current_question)
      end

      def current_question
        redis.get('current_trainer_question').to_i
      end

      def create_schedule
        redis.set('current_trainer_question', 1)
        scheduler = Rufus::Scheduler.new
        scheduler.cron(ENV['TRAINER_QUESTION_CRON']) do
          refresh
        end
      end
      Lita.register_handler(self)
    end
  end
end
