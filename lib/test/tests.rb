require 'minitest/autorun'
require_relative '../normal_form_of_lambda_expressions'

class Test < Minitest::Test
  def test_in_normal_form
    term1 = NormalFormOfLambdaExpressions::TermTree.new('λx.λy.xy')
    term2 = NormalFormOfLambdaExpressions::TermTree.new('xy')
    term3 = NormalFormOfLambdaExpressions::TermTree.new('λy.y')
    term1.to_NF
    term2.to_NF
    term3.to_NF
    assert_output(/λx.λy.xy/, '') { term1.print_tree }
    assert_output(/xy/, '') { term2.print_tree }
    assert_output(/λy.y/, '') { term3.print_tree }
  end

  def test_few_operations
    term1 = NormalFormOfLambdaExpressions::TermTree.new('((λx.λy.yx)z)v')
    term2 = NormalFormOfLambdaExpressions::TermTree.new('((λx.λy.x)(λz.z))t')
    term3 = NormalFormOfLambdaExpressions::TermTree.new('(λx.λy.xy)((λx.v)(λy.x))')
    term4 = NormalFormOfLambdaExpressions::TermTree.new('(λy.v)((λx.(xx)y)(λx.(xx)y))')
    term1.to_NF
    term2.to_NF
    term3.to_NF
    term4.to_NF
    assert_output(/vz/, '') { term1.print_tree }
    assert_output(/λz.z/, '') { term2.print_tree }
    assert_output(/λy.vy/, '') { term3.print_tree }
    assert_output(/v/, '') { term4.print_tree }
  end

  def test_a_lot_of_operations
    term1 = NormalFormOfLambdaExpressions::TermTree.new('(λx.λy.((λp.λq.p)y)x)((λz.zz)(λz.zz))s')
    term2 = NormalFormOfLambdaExpressions::TermTree.new('(λx.λy.λz.xz(yz))((λx.λy.yx)u)((λx.λy.yx)v)w')
    term1.to_NF
    term2.to_NF
    assert_output(/λy.y/, '') { term1.print_tree }
    assert_output(/λy.λz.\(yz\)\(\(\(wv\)\)\)u\)\)z\)/, '') { term2.print_tree }
  end
end