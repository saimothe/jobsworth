require "test_helper"

class CustomerTest < ActiveRecord::TestCase
  fixtures :customers

  should have_many(:task_customers).dependent(:destroy)
  should have_many(:tasks).through(:task_customers)

  def setup
    @company = Company.make
    @internal = Customer.make(:company => @company, :name => @company.name)
    @external = Customer.make(:company => @company)
  end

  def test_full_name
    assert_equal @company.name, @internal.full_name
  end

  def test_service_level_agreements_order
    @external.service_level_agreements.delete_all
    assert @external.service_level_agreements.size == 0

    one = Service.create :name => "mobile", :description => "mobile service"
    two = Service.create :name => "web", :description => "web service"
    three = Service.create :name => "car", :description => "car service"

    @external.service_level_agreements.create :billable => false, :service => one
    @external.service_level_agreements.create :billable => false, :service => two
    @external.service_level_agreements.create :billable => false, :service => three

    @external.service_level_agreements.reload

    assert @external.service_level_agreements[0].service == three
    assert @external.service_level_agreements[1].service == one
    assert @external.service_level_agreements[2].service == two

    assert @external.services[0] == three
    assert @external.services[1] == one
    assert @external.services[2] == two
  end
end







# == Schema Information
#
# Table name: customers
#
#  id           :integer(4)      not null, primary key
#  company_id   :integer(4)      default(0), not null
#  name         :string(200)     default(""), not null
#  contact_name :string(200)
#  created_at   :datetime
#  updated_at   :datetime
#  active       :boolean(1)      default(TRUE)
#
# Indexes
#
#  customers_company_id_index  (company_id,name)
#

