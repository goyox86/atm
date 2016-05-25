require "minitest/autorun"
require "bundler/setup"


class ATM
    attr_reader :notes

    # Initializes the ATM machine with the given set of notes.
    #
    # Notes have to be in the form of a Hash of notes each entry having
    # the note denomination as a key and the amount of notes as the value.
    #
    #   notes = {
    #     1 => 0,
    #     5 => 0,
    #     10 => 0,
    #     20 => 0,
    #     50 => 0,
    #     100 => 0
    #   }
    #
    #   ATM.new(notes)
    def initialize(notes)
      @notes = notes
    end

    # Returns wheter the ATM machine has no notes available.
    #
    #   atm = ATM.new({})
    #   atm.empty? # => true
    #
    #   atm = ATM.new({1: 100})
    #   atm.empty? # => false
    def empty?
      @notes.values.inject(:+) == 0
    end

    # Returns the total amount of cash available in the ATM machine.
    #
    #   atm = ATM.new({10: 1, 20: 2})
    #   atm.total_cash_available # => 50
    def total_cash_available
      total = 0
      @notes.each { |denomination, quantity| total += denomination * quantity }
      total
    end

    # Withdraws the requested +amount+ from the ATM machine.
    #
    # The result will be in the form of a Hash of notes each entry having
    # the note denomination as a key and the amount of notes as the value.
    #
    # - This method raises an EmptyATM exception in case of the ATM not having
    # any notes available.
    # - This method raises an InsufficientCash exception in case of the ATM
    # not having enough cash available to dispense the requested +amount+
    #
    #   notes = {
    #      1 => 5,
    #      5 => 10,
    #      10 => 5,
    #      20 => 5,
    #      50 => 15,
    #      100 => 10
    #    }
    #
    #   atm = ATM.new(notes)
    #   atm.withdrawn(150) # => {
    #                             100 => 1,
    #                             50 => 1
    #                           }
    def withdrawn(amount)
      raise EmptyATM if empty?
      raise InsufficientCash if total_cash_available < amount

      notes = Hash.new(0)

      remaining_amount = amount
      [100, 50, 20, 10, 5, 1].each do |note|
        while remaining_amount > 0
          break if note > remaining_amount

          remaining_amount -= note
          @notes[note] -= 1
          notes[note] += 1
        end
      end

      notes
    end
end

class EmptyATM < StandardError; end
class InsufficientCash < StandardError; end

class TestATM < Minitest::Test
    def setup
        notes = {
            1 => 5,
            5 => 10,
            10 => 5,
            20 => 5,
            50 => 15,
            100 => 10
        }

        @atm = ATM.new(notes)
    end

    def test_empty_atm
      notes = {
          1 => 0,
          5 => 0,
          10 => 0,
          20 => 0,
          50 => 0,
          100 => 0
      }

      assert_raises EmptyATM do
        ATM.new(notes).withdrawn(100)
      end
    end

    def test_withdrawn_exact_amount
        expected_notes = {
            100 => 3
        }
        assert_equal expected_notes, @atm.withdrawn(300)
    end

    def test_withdrawn_composed_amount_dozens
        expected_notes = {
            100 => 2,
            10 => 1
        }
        assert_equal expected_notes, @atm.withdrawn(210)
    end

    def test_withdrawn_composed_amount_dozens_units
        expected_notes = {
            100 => 1,
            50 => 1,
            1 => 1
        }
        assert_equal expected_notes, @atm.withdrawn(151)
    end

    def test_withdrawn_composed_amount_only_units
        expected_notes = {
            1 => 3
        }
        assert_equal expected_notes, @atm.withdrawn(3)
    end

    def test_atm_remaining_notes_is_consistent
      expected_notes = {
        1 => 3,
        5 => 10,
        10 => 5,
        20 => 4,
        50 => 14,
        100 => 5
      }

      @atm.withdrawn(572)
      assert_equal expected_notes, @atm.notes
    end

    def test_total_cash_available
      notes = {
        1 => 10,
        5 => 10,
        10 => 10,
        20 => 10,
        50 => 10,
        100 => 10
      }

      assert_equal 1860, ATM.new(notes).total_cash_available
    end

    def test_insufficient_funds
      notes = {
        1 => 10,
        5 => 10
      }

      assert_raises InsufficientCash do
        ATM.new(notes).withdrawn(100)
      end
    end
end
