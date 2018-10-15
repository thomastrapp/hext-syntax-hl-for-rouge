# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Hext < RegexLexer
      title "Hext"
      desc "A Domain-specific language for extracting structured data from HTML"
      tag 'hext'
      filenames '*.hext'

      tagRx = /\??[_\*a-z][-_a-z0-9]*/i
      # https://stackoverflow.com/questions/6331065/matching-balanced-parenthesis-in-ruby-using-recursive-regular-expressions-like-p
      balancedParensRx = %r{(?<re>\((?:(?> [^()]+ )|\g<re>)*\))}x
      attributeRx = /[@a-z0-9_\-]+/
      matchOperatorRx = /(?:==)|(?:\$=)|(?:\*=)|(?:=)|(?:\^=)/
      singleQuoteRx = /'(?:[^'\\]|\\.)*'/
      doubleQuoteRx = /"(?:[^"\\]|\\.)*"/
      nodeTraits = %w(
        empty child-count attribute-count nth-child
        nth-last-child nth-of-type first-child first-of-type
        last-child last-of-type nth-last-of-type only-child
        only-of-type not
      )
      stringPipes = %w(
        trim tolower toupper collapsews
        prepend append filter replace
      )

      state :root do
        rule /\s+/m, Text
        rule /#.*$/, Comment

        rule /<\/#{tagRx}>/, Name::Tag
        rule /<#{tagRx}/, Name::Tag, :ruleDefinition
      end

      state :ruleDefinition do
        rule /:/, Operator, :pipe
        rule /\s+/m, Text, :ruleAttributes
        rule /\/?>/, Name::Tag, :pop!
        rule //, Text, :pop!
      end

      state :pipe do
        rule /[a-z\-_]+/i do |m|
          if nodeTraits.include? m[0]
            token Name::Builtin
          elsif stringPipes.include? m[0]
            token Name::Builtin
          else
            token Keyword
          end
        end

        rule /(\()(\/.*?\/[ci]*)(\))/ do
          groups Text, Name::Function, Text
        end
        rule /(\()(#{singleQuoteRx})(\))/ do
          groups Text, Literal::String, Text
        end
        rule /(\()(#{doubleQuoteRx})(\))/ do
          groups Text, Literal::String, Text
        end
        rule balancedParensRx, Text

        rule //, Text, :pop!
      end

      state :ruleAttributes do
        rule /\s+/m, Text
        rule attributeRx, Name::Attribute, :attribute
        rule //, Name::Tag, :pop!
      end

      state :attribute do
        rule matchOperatorRx, Operator, :attributeValue
        rule //, Text, :pop!
      end

      state :attributeValue do
        rule singleQuoteRx, Literal::String::Single, :pop!
        rule doubleQuoteRx, Literal::String::Double, :pop!
        rule //, Text, :pop!
      end
    end
  end
end
