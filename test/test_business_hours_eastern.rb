require 'helper'

describe "business hours" do
  describe "with a TimeWithZone object in US Eastern" do
    before do
      Time.zone = 'Eastern Time (US & Canada)'
    end

    describe "when adding/subtracting positive business hours" do
      it "move to tomorrow if we add 8 business hours" do
        first = Time.zone.parse("Aug 4 2010, 9:35 am")
        later = 8.business_hours.after(first)
        expected = Time.zone.parse("Aug 5 2010, 9:35 am")
        assert_equal expected, later
      end

      it "move to yesterday if we subtract 8 business hours" do
        first = Time.zone.parse("Aug 4 2010, 9:35 am")
        before = 8.business_hours.before(first)
        expected = Time.zone.parse("Aug 3 2010, 9:35 am")
        assert_equal expected, before
      end

      it "take into account a weekend when adding an hour" do
        friday_afternoon = Time.zone.parse("April 9th 2010, 4:50 pm")
        monday_morning = 1.business_hour.after(friday_afternoon)
        expected = Time.zone.parse("April 12th 2010, 9:50 am")
        assert_equal expected, monday_morning
      end

      it "take into account a weekend when subtracting an hour" do
        monday_morning = Time.zone.parse("April 12th 2010, 9:50 am")
        friday_afternoon = 1.business_hour.before(monday_morning)
        expected = Time.zone.parse("April 9th 2010, 4:50 pm")
        assert_equal expected, friday_afternoon
      end

      it "take into account a holiday" do
        BusinessTime::Config.holidays << Date.parse("July 5th, 2010")
        friday_afternoon = Time.zone.parse("July 2nd 2010, 4:50pm")
        tuesday_morning = 1.business_hour.after(friday_afternoon)
        expected = Time.zone.parse("July 6th 2010, 9:50 am")
        assert_equal expected, tuesday_morning
      end

      it "add hours in the middle of the workday"  do
        monday_morning = Time.zone.parse("April 12th 2010, 9:50 am")
        later = 3.business_hours.after(monday_morning)
        expected = Time.zone.parse("April 12th 2010, 12:50 pm")
        assert_equal expected, later
      end

      it "roll forward to 9 am if asked in the early morning" do
        crack_of_dawn_monday = Time.zone.parse("Mon Apr 26, 04:30:00, 2010")
        monday_morning = Time.zone.parse("Mon Apr 26, 09:00:00, 2010")
        assert_equal monday_morning, Time.roll_forward(crack_of_dawn_monday)
      end

      it "roll forward to the next morning if aftern business hours" do
        monday_evening = Time.zone.parse("Mon Apr 26, 18:00:00, 2010")
        tuesday_morning = Time.zone.parse("Tue Apr 27, 09:00:00, 2010")
        assert_equal tuesday_morning, Time.roll_forward(monday_evening)
      end

      it "consider any time on a weekend as equivalent to monday morning" do
        sunday = Time.zone.parse("Sun Apr 25 12:06:56, 2010")
        monday = Time.zone.parse("Mon Apr 26, 09:00:00, 2010")
        assert_equal 1.business_hour.before(monday), 1.business_hour.before(sunday)
      end
    end

    describe "when adding/subtracting negative business hours" do
      it "move to yesterday if we add -8 business hours" do
        first = Time.zone.parse("Aug 5 2010, 9:35 am")
        before = -8.business_hours.after(first)
        expected = Time.zone.parse("Aug 4 2010, 9:35 am")
        assert_equal expected, before
      end

      it "move to tomorrow if we subtract -8 business hours" do
        first = Time.zone.parse("Aug 3 2010, 9:35 am")
        later = -8.business_hours.before(first)
        expected = Time.zone.parse("Aug 4 2010, 9:35 am")
        assert_equal expected, later
      end

      it "take into account a weekend when adding a negative hour" do
        monday_morning = Time.zone.parse("April 12th 2010, 9:50 am")
        friday_afternoon = -1.business_hour.after(monday_morning)
        expected = Time.zone.parse("April 9th 2010, 4:50 pm")
        assert_equal expected, friday_afternoon
      end

      it "take into account a weekend when subtracting a negative hour" do
        friday_afternoon = Time.zone.parse("April 9th 2010, 4:50 pm")
        monday_morning = -1.business_hour.before(friday_afternoon)
        expected = Time.zone.parse("April 12th 2010, 9:50 am")
        assert_equal expected, monday_morning
      end

      it "take into account a holiday" do
        BusinessTime::Config.holidays << Date.parse("July 5th, 2010")
        tuesday_morning = Time.zone.parse("July 6th 2010, 9:50 am")
        friday_afternoon = -1.business_hour.after(tuesday_morning)
        expected = Time.zone.parse("July 2nd 2010, 4:50 pm")
        assert_equal expected, friday_afternoon
      end

      it "add negative hours in the middle of the workday"  do
        monday_afternoon = Time.zone.parse("April 12th 2010, 12:50 pm")
        before = -3.business_hours.after(monday_afternoon)
        expected = Time.zone.parse("April 12th 2010, 9:50 am")
        assert_equal expected, before
      end

      it "consider any time on a weekend as equivalent to monday morning" do
        sunday = Time.zone.parse("Sun Apr 25 12:06:56, 2010")
        monday = Time.zone.parse("Mon Apr 26, 09:00:00, 2010")
        assert_equal(-1.business_hour.before(monday), -1.business_hour.before(sunday))
      end
    end
  end
end
