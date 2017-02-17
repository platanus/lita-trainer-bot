require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/trainer_bot"
require "lita/services/spreadsheet_service"

Lita::Handlers::TrainerBot.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)
