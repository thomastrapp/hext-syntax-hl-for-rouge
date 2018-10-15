# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::Hext do
  let(:subject) { Rouge::Lexers::Hext.new }
  include Support::Lexing

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'foo.hext'
    end
  end
end
