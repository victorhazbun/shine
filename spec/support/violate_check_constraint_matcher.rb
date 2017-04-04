RSpec::Matchers.define :violate_check_constraint do |constraint_name| # (1)
  supports_block_expectations                                         # (2)
  match do |code_to_test|                                             # (3)
    begin
      code_to_test.()                                                 # (4)
      false                                                           # (5)
    rescue ActiveRecord::StatementInvalid => ex                       # (6)
      ex.message =~ /#{constraint_name}/                              # (7)
    end
  end
end

