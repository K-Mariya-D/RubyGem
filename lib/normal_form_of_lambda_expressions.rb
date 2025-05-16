module NormalFormOfLambdaExpressions
end


class Variable
    attr_accessor :value, :parent, :next

    def initialize(value, parent = nil, nxt = nil)
        @value = value
        @parent = parent
        @next = nxt
    end

    def to_s
        "#{@value}"
    end

end

class Lyambda
    attr_accessor :value, :parent, :next 

    def initialize(value, parent = nil, nxt = nil)
        @value = value
        @parent = parent
        @next = nxt
    end

    def to_s
        "(λ#{@value}.)"
    end

end

class App
    attr_accessor :parent, :left, :right

    def initialize(left, right, parent = nil)
        @parent = parent
        @left = left
        @right = right
    end

end

class TermTree
    attr_reader :root, :FV, :BV, :parser

    def initialize(input)
        @parser = Parser.new()
        @root = @parser.parse(input) 
        @FV = nil
        @BV = nil 
    end

    def print
        current_node = @root
        queue = Queue.new

        until current_node == nil && queue.empty?
            if current_node == nil
                node = queue.pop
                current_node = node.right
            end
            if current_node.is_a?(Lyambda) || current_node.is_a?(Variable)
                puts current_node.to_s
                current_node = current_node.next
            else 
                queue << current_node
                current_node = current_node.left
            end
        end
    end

end

private :Parser

class Parser
    attr_reader :input, :index, :current_node

    def parse(input)
        @input = input.gsub(/\\s+/, "") # Удаляем пробелы
        @index = 0
        @current_node = nil
        parse_term
    end

    def to_first_node
        until current_node.parent == nil
            current_node = current_node.parent
        end
    end

    def parse_term

        add_application

        #пропускаем незначащие скобки
        if current_char == '(' || current_char == ')'
            @index += 1
            parse_term
        end

        if current_char == 'λ' || current_char.downcase == 'l' 
            change_node(parse_abstraction)
        elsif current_char =~ /[a-zA-Z]/
            change_node(parse_variable)
        else
            change_node(parse_application)
        end

        if @index == @input.length
            to_first_node
        end
    end
    
    def add_application
        # Поднимаемся вверх по дереву и вставляем App
        if current_char == '(' && @input[@index - 1] == ')'
            until current_node.parent == nil || current_node.parent.is_a?(App)
                current_node = current_node.parent
            end
            if current_node.parent == nil
                app = App.new(current_node, nil)
                current_node.parent = app
            else
                app = App.new(current_node, nil, current_node.parent)
                current_node.parent.right = app
                current_node.parent = app
            end
            @index += 1
        end
    end

    def parse_abstraction
        consume(['λ', 'l', 'L'])
        variable = parse_variable
        consume('.')
        body = parse_term
        Abstraction.new(variable, current_node, body)
    end
    
    def parse_variable
        var_name = current_char
        consume(var_name)
        Variable.new(var_name, current_node)
    end
    
    def parse_application
        function = parse_term
        argument = parse_term
        App.new(function, argument, current_node)
    end
    
    def change_node(next_node)
        if current_node.is_a?(Lyambda) || current_node.is_a?(Variable)
            current_node.next = next_node
            current_node = current_node.next
        else 
            current_node.right = next_node
            current_node = current_node.right
        end
    end
    
    def current_char
        @input[@index]
    end
    
    def consume(expected_chars)
        expected_chars.each do |char|
            raise "Unexpected character: #{current_chars}" unless char == current_char
        end
        @index += 1
    end
end
