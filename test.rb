require_relative 'lib/normal_form_of_lambda_expressions'

 term = NormalFormOfLambdaExpressions::TermTree.new('(λx.λy.xy)((λx.v)(λy.x))')
 term.print 