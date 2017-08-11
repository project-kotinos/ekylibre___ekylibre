module Backend
  module BankReconciliation
    # Handles bank reconciliation lettering.
    class LettersController < Backend::BaseController
      def create
        return unless find_cash

        bank_items     = BankStatementItem.where(id: params[:bank_statement_items])
        journal_items  = JournalEntryItem.where(id: params[:journal_entry_items])

        new_letter = @cash.letter_items(bank_items, journal_items)
        return head(:bad_request) unless new_letter

        respond_to do |format|
          format.json {  render json: { letter: new_letter } }
        end
      end

      def destroy
        return unless request.xhr?

        @cash = Cash.find(params[:cash_id])
        @cash = @cash.first if @cash.is_a?(Array)
        return unless @cash

        #if params[:type] == "journal_entry_item"
          #@bank_statement = JournalEntryItem.find_by(id: params[:id]).bank_statement
        #else
          #@bank_statement = BankStatementItem.find_by(id: params[:id]).bank_statement
        #end
        #return unless @bank_statement

        letter = params[:letter]
        JournalEntryItem
          .pointed_by_letters(letter, @cash)
          .update_all(bank_statement_letter: nil, bank_statement_id: nil)


        BankStatement
          .find_by_cash(@cash)
          .map(&:items)
          .flatten
          .select{ |bank_statement_item| bank_statement_item.letter == letter }
          .map{ |bank_statement_item| bank_statement_item.update(letter: nil) }

        respond_to do |format|
          format.json {  render json: { letter: letter } }
        end
      end

      private

      def find_bank_statement
        @bank_statement = BankStatement.find_by(id: params[:bank_statement_id])
        @bank_statement || (head(:bad_request) && nil)
      end

      def find_cash
        @cash = Cash.find_by(id: params[:cash_id])
        @cash || (head(:bad_request) && nil)
      end
    end
  end
end
