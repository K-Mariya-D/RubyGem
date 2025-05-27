module NormalFormOfLambdaExpressions

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
        "λ#{@value}."
    end

end

class App
    attr_accessor :parent, :left, :right

    def initialize(left, right, parent = nil)
        @parent = parent
        @left = left
        @right = right
    end

    def to_s
        "App"
    end
end

class Dummy
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

class TermTree
    attr_reader :root, :FV, :BV, :parser

    def initialize(input)
        @parser = Parser.new
        @root = @parser.parse(input) 
        @FV = FV(@root, @root, Set.new)
        @BV = BV(@root, Set.new)
    end

    def print_tree
        print_node(@root)
    end
    #Проходит по дереву пока может, находя редексы (App по левому поддереву) и применяя к ним правила  
    def to_NF()
        #puts 'to_NF'
        print_tree 
        puts
        stack = []
        stack << @root
        until stack.empty?
            current_node = stack.pop
            #puts "current node is #{current_node}"
            if current_node.is_a?(App) && current_node.left.is_a?(Lyambda)
                #puts "and is redeks"
                break
            end
            if current_node.is_a?(App)
                #puts "right: #{current_node.right} left: #{current_node.left}"
                stack.push(current_node.right) unless current_node.right == nil
                stack.push(current_node.left) unless current_node.left == nil
            else
                #puts "next: #{current_node.next}"
                stack.push(current_node.next) unless current_node.next == nil
            end
        end
        if current_node.is_a?(App) && current_node.left.is_a?(Lyambda)
            #puts "redeks is (#{current_node.left})(#{current_node.right})"
            n = current_node.right
            x = current_node.left.value
            m = current_node.left.next
            current_node.right = nil
            m.parent = current_node.parent
            if current_node.parent.is_a?(App)
                current_node.parent.right = m if current_node.parent.right == current_node
                current_node.parent.left = m if current_node.parent.left == current_node
            else
                current_node.parent.next = m if current_node.parent != nil 
            end
            @root = m if current_node == @root
            current_node = m
            #puts "#{current_node} #{@root}"
            apply_the_rule(n, x, m)
            to_NF
        end
    end
    
private
    def print_node(node, count = 0) 
        if node != nil 
            if node.parent.is_a?(App) && !node.is_a?(Variable)
                print '('
                count = count + 1        
            end
            if node.is_a?(App) 
                #print 'App'
                print_node(node.left, count); 
                print_node(node.right, count); 
            else  
                print node.to_s
                if node.next == nil && !(node.parent.is_a?(App) && node.is_a?(Variable) && node.parent.left == node)
                    print ')' * count
                    count = count - 1
                end
                print_node(node.next, count) 
            end
        end
    end
    #Рекурсивно проходит вниз по дереву и собирает множество свободных переменных
    def FV(start, node, fv)
        if node != nil            
            if node.is_a?(App)
                FV(start, node.left, fv)
                FV(start, node.right, fv)
            elsif node.is_a?(Variable)
                prev_node = node.parent
                until prev_node == start.parent
                    if prev_node.is_a?(Lyambda) && prev_node.value == node.value
                        break
                    end
                    prev_node = prev_node.parent
                end
                fv << node.value if prev_node == start.parent 
                FV(start, node.next, fv)
            else 
                FV(start, node.next, fv)
            end
        else
            return fv
        end
    end
    #Рекурсивно проходит вниз по дереву и собирает множество связных переменных
    def BV(node, bv)
        if node != nil 
            if node.is_a?(App) 
                BV(node.left, bv);
                BV(node.right, bv);
            else 
                bv << node.value if node.is_a?(Lyambda)
                BV(node.next, bv)
            end
        else
            return bv
        end 
    end
    #выбирает, какое правило применить к редексу и применяет его 
    def apply_the_rule(n, x, m)
        #puts 'apply_the_rule'
        #puts "N: #{n}, x: #{x}, M: #{m}"
        if m.is_a?(Variable)
            rule1(n, m) if m.value == x 
            rule2(n, x, m.value) if m.value != x
        elsif m.is_a?(App)
            rule3(n, x, m)
        elsif m.is_a?(Lyambda) 
            p = m.next
            y = m.value
=begin
            puts 'FV from p:'
            FV(p, p, Set.new).each do |elem|
                puts elem
            end
=end
            if x == y
                rule4(n, x, m)
            elsif !FV(p, p, Set.new).include?(x)
                rule5(n, x, m)
            elsif !FV(n, n, Set.new).include?(y) 
                rule6(n, x, m)
            else 
                rule7(n, x, m)
            end
        end
    end
    def rule1(n, x)
        puts 'rule 1'
        n.parent = x.parent
        if x.parent.is_a?(App)
            x.parent.right = n if x.parent.right == x
            x.parent.left = n if x.parent.left == x
        else
            x.parent.next = n
        end
        return n
    end

    def rule2(n, x, y)
        puts 'rule 2'
        return y
    end

    def rule3(n, x, app)
        puts 'rule 3'
        p = app.left
        q = app.right
        #puts "p: #{p}, q: #{q}"
        apply_the_rule(n, x, p)
        apply_the_rule(n, x, q)
    end

    def rule4(n, x, l)
        puts 'rule 4'
        return l
    end

     def rule5(n, x, l)
        puts 'rule 5'
        return l
    end
    
    def rule6(n, x, l)
        puts 'rule 6'
        apply_the_rule(n, x, l.next)
    end

    def rule7(n, x, l)
        puts 'rule 7'
        p = l.next 
        np = App.new(n, p)
        alphabet = 'abcdefghijklmnopqrstuvwxyz'.reverse!
        z = ''
        alphabet.each_char do |char|
            if char != x && !FV(np, np, Set.new).include?(char)
                z = char
                break 
            end
        end

        body = Variable.new(z)
        body = apply_the_rule(body, l.value, p)
        n = apply_the_rule(n, x, body)
        n = Lyambda.new(z, l.parent, n)        
        if l.parent.is_a?(App)
            l.parent.right = n if l.parent.right == l
            l.parent.left = n if l.parent.left == l
        else
            l.parent.next = n
        end
        return n
    end
end

class Parser
    attr_reader :input, :index, :current_node, :que, :root

    def parse(input)
        @input = input.gsub(/\\s+/, "") # Удаляем пробелы
        @index = 0
        @current_node = nil 
        @que = Queue.new 
        parse_dummy(input)
    end

private
    # xy, (term)(term), M(term), (term)M,
    #Находит в каких местах терм должен делиться на части (App) и формирует массив пар [start, end],
    #где start - начало одной из частей, end - её конец  
    def parse_for_app(input)
        part = ''
        brackets = []
        indexes = []
        start_ind = 0
        end_ind = input.length - 1

        input.each_char.with_index do |char, index|
            if char == '('
                brackets.push(index)
            elsif char == ')'
                if brackets.length == 1 
                    start_ind = brackets.pop + 1
                    end_ind = index - 1
                    indexes << [start_ind, end_ind]
                else
                    brackets.pop 
                end
            end 
        end
        if indexes.length >= 2  
            if indexes[0][0] > 1
                #puts 'x(term)(term)'
                first = [0, indexes[0][0] - 2]
                second = [indexes[0][0] - 1, indexes[indexes.length - 1][1] + 1]
                indexes = []
                indexes << first
                indexes << second
            elsif indexes[indexes.length - 1][1] < input.length - 2
                #puts '(term)(term)x'
                first = [indexes[0][0], indexes[0][1]]
                second = [indexes[1][0] - 1, input.length - 1]
                indexes = []
                indexes << first
                indexes << second
            elsif indexes.length > 2
                #puts '(term)(term)(term)'
                first = [indexes[0][0], indexes[0][1]]
                second = [indexes[1][0] - 1, indexes[indexes.length - 1][1] + 1]
                indexes = []
                indexes << first
                indexes << second
            end
        elsif indexes.length == 0
            indexes << [0, 0]
            indexes << [1, 1]
        elsif indexes.length < 2
            if start_ind > 1
                indexes << [0, start_ind - 1]
            else 
                indexes << [end_ind + 2, input.length - 1]
            end
        end
=begin
        indexes.each do |elem|
          puts "[#{elem[0]} #{elem[1]}]"
        end
=end
        return indexes
    end

    #По сформированному массиву частей добавляет к текущему дереву App (чьи дети - фиктивные элементы) 
    def add_apps(input, side = nil)
        indexes = parse_for_app(input)
        #puts "Input: #{input}, Parts: #{indexes.length}"
        indexes.each.with_index do |i, ind|
            if @current_node.is_a?(App) && ind != 0
                dummy = Dummy.new(input[i[0]..i[1]], @current_node)
                @current_node.right = dummy
                @current_node = @current_node.right
                #puts "curent_node in App right - #{dummy.value} "
                @que.push(@current_node)
            elsif @current_node.is_a?(App) && ind == 0 
                dummy = Dummy.new(input[i[0]..i[1]])
                app = App.new(dummy, nil, @current_node)
                dummy.parent = app
                if side == 'right'
                    @current_node.right = app
                    @current_node = @current_node.right
                elsif side == 'left' 
                    @current_node.left = app
                    @current_node = @current_node.left
                end
                #puts "!!!curent_node - App, with left #{dummy.value} "
                @que.push(dummy)
            else
                dummy = Dummy.new(input[i[0]..i[1]])
                app = App.new(dummy, nil, @current_node)
                dummy.parent = app
                @current_node.next = app if @current_node != nil
                if @current_node != nil
                    @current_node = @current_node.next 
                else 
                    @current_node = app
                end
                #puts "curent_node - App, with left #{dummy.value} "
                @que.push(dummy)
            end
        end
    end

    #Проходиться по дереву, разбивая его на фиктивные node'ы, а после заменяет фиктивные node'ы на настоящие элементы (Lyambda, Variable)
    def parse_dummy(input)
        #puts input
        if input =~ /'[()]'/
            add_apps(input)
        else
            dummy = Dummy.new(input)
            @current_node = dummy
            @que.push(@current_node)
        end
        
        until @que.empty?
            @current_node = @que.pop
            #puts "value: #{@current_node}, parent: #{@current_node.parent}"
            if @current_node.is_a?(App)
                #puts 'parse app'
                @que.push(@current_node.left) if @current_node.left != nil && @current_node.left.is_a?(Dummy) 
                @que.push(@current_node.right) if @current_node.right != nil && @current_node.right.is_a?(Dummy) 
            elsif @current_node.value.length == 1 
                #puts "parse variable - #{@current_node.value}"
                var = Variable.new(@current_node.value, @current_node.parent, @current_node.next)
                if @current_node.parent.is_a?(Lyambda)
                    @current_node.parent.next = var
                else # привязка ноды, если родитель - App
                    @current_node.parent.right = var if @current_node.parent != nil &&  @current_node.parent.right == @current_node
                    @current_node.parent.left = var if @current_node.parent != nil && @current_node.parent.left == @current_node
                end
                @que.push(var.next) if var.next != nil && var.next.is_a?(Dummy) 
                @current_node.parent = nil
                @current_node.next = nil
                @current_node = var
            elsif @current_node.value[0] == 'λ' ||  @current_node.value[0].downcase == 'l'
                #puts "parse lyambda - #{@current_node.value}"
                l = Lyambda.new(@current_node.value[1], @current_node.parent)
                #puts "lyambda vale = #{l.value}"
                if @current_node.parent.is_a?(Lyambda) || @current_node.parent.is_a?(Variable)
                    @current_node.parent.next = l
                else # привязка ноды, если родитель - App
                    @current_node.parent.right = l if @current_node.parent != nil && @current_node.parent.right == @current_node
                    @current_node.parent.left = l if @current_node.parent != nil && @current_node.parent.left == @current_node 
                end
                dummy = Dummy.new(@current_node.value[3..], l, @current_node.next)
                l.next = dummy
                @current_node = l
                @que.push(dummy)
                #puts "next for parse - #{dummy.value}"
            else
                #puts 'parse dummy'
                node = @current_node
                side = nil
                @current_node = node.parent
                if @current_node.is_a?(Lyambda) || @current_node.is_a?(Variable)
                    @current_node.next = nil
                else
                    if @current_node != nil && @current_node.right == node
                        @current_node.right = nil
                        side = 'right'
                    elsif @current_node != nil && @current_node.left == node
                        @current_node.left = nil 
                        side = 'left'
                    end
                end
                add_apps(node.value, side) if node != nil
            end             
        end
        to_first_node
    end

    def to_first_node
        #puts "to_first_node"
        #puts "node - #{@current_node}, parent - #{@current_node.parent}"
        until @current_node.parent == nil
            @current_node = @current_node.parent
        end
        return @current_node
    end

=begin   
    def current_char
        @input[@index]
    end
    
    def consume(expected_chars)
        raise "Unexpected character: #{current_char}" unless expected_chars.include?(current_char)
        @index += 1
    end
=end
end
end
