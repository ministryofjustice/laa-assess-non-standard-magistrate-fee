module Uplift
  class LettersAndCallsForm < BaseForm
    SCOPE = 'letters_and_calls'

    class Remover < Uplift::RemoverForm
      LINKED_CLASS = V1::LetterAndCall
    end
  end
end