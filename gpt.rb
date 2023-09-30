require 'chatgpt/client'
require 'json'

#response = client.chat(messages)
#
#response.each do |k,v|
#   # puts "#{k}  Key "
#   # puts "#{v} value"
#end
#
#choices=response["choices"]

#arr=choices[0]
#message=arr["message"]
#content=message["content"]
#puts content

#choices.each do |k,v|
#     puts "#{k}  Key "
#     puts "#{v} value"
#end
#
#puts choices.class
#choices[0].each do |k,v|
#    puts "#{k}  Key "
#    puts "#{v} value"
#end

#require 'yandex-translator'
require 'socket'
#translator = Yandex::Translator.new('trnsl.1.1.20180731T232407Z.2d3b500877260736.d6a4b1322b8071c460e3c3b8eab22c210dcc6c06')
#puts (translator.translate 'ブラブラブラ', from: 'en')

#line_as_string="meowko :カナダ何年住んでらっしゃるんですか？"
#x=line_as_string.split("meowko")[-1]
#puts x
#puts (translator.detect("meowko :カナダ何年住んでらっしゃるんですか？"))

TWITCH_HOST="irc.twitch.tv"
TWITCH_PORT=6667	

class TwitchBot
    api_key = ''
    client = ChatGPT::Client.new(api_key)

 
#
	def initialize
		#@translator=Yandex::Translator.new('trnsl.1.1.20180731T232407Z.2d3b500877260736.d6a4b1322b8071c460e3c3b8eab22c210dcc6c06')
		@nickname="question_chat_gpt"
		@password=""
		@channel=""
		@socket=TCPSocket.open(TWITCH_HOST, TWITCH_PORT)
        @api_key = ''
        @client = ChatGPT::Client.new(@api_key)
		write_to_system(twitch_data)
		write_to_system  "PASS #{@password}"
		write_to_system	 "NICK #{@nickname}"
		write_to_system	 "USER #{@nickname} 0 * #{@nickname} "
		write_to_system  "JOIN ##{@channel}"
	end
    def question_to_ask(question)
        messages = [
        {
        role: "user",
        content: question
        }
        ]
        messages
    end
	
	
	def twitch_data
		<<~DATA
			CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership
		DATA
	end


	def write_to_system(message)
		@socket.puts message
		
	end

	def write_to_chat(message)
		write_to_system "PRIVMSG ##{@channel} :#{message}"
	end

	def is_broadcaster?(string)
		string.include?("broadcaster")
	end

 
	def run 
		until @socket.eof? do
			message=@socket.gets
			#puts message
			line_as_string=message

			
			split_message=line_as_string.split("!question")[-1]
			puts split_message
			if split_message.include?("subscriber")
				puts "sub"
			end
			if is_broadcaster?(split_message)
				puts "Broadcaster"
			end
			#if @translator.detect(split_message)=='ja'
			#	write_to_chat(@translator.translate(split_message , from: 'en'))
			#end
			
            
            
			
             #&& message.include?("moderator")
			message=message.split("#" + @channel)[-1]
			#puts message.include?("!question")
            messages=question_to_ask(split_message)
            if message.include?("!question")
			response = @client.chat(messages)
			
            #puts response
            choices=response["choices"]
            arr=choices[0]
            message=arr["message"]
            content=message["content"]
            content.gsub!(/[\n]+/, ' ')

			write_to_system(content)
            write_to_chat(content[0...300])
            end
		end
	end

end

bot=TwitchBot.new
bot.run
