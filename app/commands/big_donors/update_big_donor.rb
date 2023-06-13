module BigDonors
  class UpdateBigDonor < ApplicationCommand
    prepend SimpleCommand

    attr_reader :big_donor_params

    def initialize(big_donor_params)
      @big_donor_params = big_donor_params
    end

    def call
      with_exception_handle do
        big_donor = BigDonor.find(big_donor_params[:id])
        big_donor.update!(big_donor_params)

        big_donor
      end
    end
  end
end
