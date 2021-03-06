require "spec_helper"

describe Lita::Handlers::TrainerBot, lita_handler: true do
  let(:carl) { Lita::User.create(123, name: "carlos") }
  it "has an index" do
    send_command("en qué pregunta vamos?", as: carl)
    expect(replies.last).to eq("Vamos en la número 1")
  end
  it "changes the index when told" do
    send_command("muévete a la pregunta 5", as: carl)
    expect(replies.last).to eq("Ok, entonces vamos en la número 5")
  end
  it "knows the right answer" do
    send_command("muévete a la pregunta 2", as: carl)
    send_command("dime la respuesta porfa", as: carl)
    expect(replies.last).to eq("La respuesta correcta es la d")
  end
  it "evaluates an answer" do
    send_command("muévete a la pregunta 2", as: carl)
    send_command("es la d?", as: carl)
    expect(replies.last).to eq("Sí! la d!")
  end
end
