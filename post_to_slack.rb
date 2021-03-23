require "slack-ruby-client"
require_relative "utils"

class PostToSlack
  include Thor::Shell
  include Utils

  def initialize
    @client = Slack::Web::Client.new(token: ENV.fetch("SLACK_API_TOKEN"))
  end

  def call
    message = case prompt_for_message_type
    when "s", "standup"
      prompt_for_standup_msg
    when "n", "normal"
      prompt_for_normal_msg
    else
      raise "We need to handle a new Slack message type."
    end

    post(message)
  end

  private

  attr_reader :client

  def prompt_for_message_type
    ask("What kind of Slack message shall we send?([s]tandup [n]ormal)")
  end

  def prompt_for_standup_msg
    @yesterday = ask "What happened yesterday? What went well? What didn’t?"
    @today = ask "What are you planning to work on today? Any blockers?"
    @other = ask "Anything else the team should know?"
    template_string("slack_standup.erb")
  end

  def prompt_for_normal_msg
    ask "What would you like to say?"
  end

  def post(message)
    client.chat_postMessage(
      channel: "@bweave",
      text: message,
      as_user: true,
      icon_url: "https://ca.slack-edge.com/T024L9M0Y-U5767U2TX-9007e0365f04-72",
    )
  end
end