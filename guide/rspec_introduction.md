# RSpec Testing Guide for Ruby on Rails

Welcome to writing tests in Rails! Since your project uses **RSpec** (via the `rspec-rails` gem), this guide focuses on RSpec concepts, structures, and matchers.

---

## 1. The Core Structure of a Test

An RSpec test file (usually ending in `_spec.rb`) is organized hierarchically using blocks.

```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  # 'describe' groups tests around a specific class, method, or feature
  describe "#full_name" do
    
    # 'context' describes a specific state or scenario (usually starts with "when" or "with")
    context "when first name and last name are present" do
      
      # 'it' (or 'specify') defines an individual test case (an example)
      it "returns the concatenated full name" do
        user = User.new(first_name: "John", last_name: "Doe")
        
        # An assertion (Expectation)
        expect(user.full_name).to eq("John Doe")
      end
    end

    context "when last name is missing" do
      it "returns only the first name" do
        user = User.new(first_name: "John", last_name: nil)
        expect(user.full_name).to eq("John")
      end
    end
  end
end
```

---

## 2. What is an Expectation and a Matcher?

An **expectation** is the assertion you make in a test. 
A **matcher** is the helper method used to verify if the subject meets that expectation.

Syntax: `expect(actual_value).to matcher(expected_value)` or `expect(actual_value).not_to matcher(...)`

### Common Matchers

#### Equivalence & Identity
*   `eq(value)`: Checks if actual == expected (value equality).
    ```ruby
    expect(1 + 1).to eq(2)
    ```
*   `be(value)`: Checks if actual and expected are the exact same object (object identity).

#### Truthiness & Nil
*   `be_truthy` / `be_falsey`: Checks if the value is truthy (not `nil` or `false`) or falsey (`nil` or `false`).
*   `be_nil`: Checks if the value is exactly `nil`.
    ```ruby
    expect(user.middle_name).to be_nil
    ```

#### Comparisons
*   `be > number`, `be >= number`, `be < number`
*   `be_between(min, max).inclusive`

#### Collections (Arrays/Hashes)
*   `include(element)`: Checks if an array, hash, or string contains the item.
    ```ruby
    expect([1, 2, 3]).to include(2)
    expect("hello world").to include("hello")
    ```
*   `match_array([...])`: Checks if an array contains exactly the specified elements, regardless of order.

#### Predicate Matchers
If a Ruby object has a method ending in `?` (e.g., `visible?`, `empty?`, `valid?`), RSpec lets you dynamically use a `be_` matcher:
*   `user.valid?` $\rightarrow$ `expect(user).to be_valid`
*   `array.empty?` $\rightarrow$ `expect(array).to be_empty`

#### Changing State
Use `change` to verify if an action modifies a database count or attribute:
```ruby
expect {
  user.save
}.to change(User, :count).by(1)
```

---

## 3. Test Setup: `let`, `let!`, and `before`

Instead of local variables, RSpec uses `let` and `before` blocks to set up test data.

### `let` vs `let!`
*   `let(:symbol) { ... }`: **Lazy-evaluated**. The block is only run when you call `symbol` for the first time inside an `it` block.
*   `let!(:symbol) { ... }`: **Eager-evaluated**. The block is run *before* every `it` block in that scope, whether you reference it or not.

### `before`
Runs a block of code before each test. Best for setup actions that don't return a value you need to reference.
```ruby
before do
  # Perform some setup action
  allow(Stripe::Charge).to receive(:create).and_return(true)
end
```

---

## 4. Creating Test Data with FactoryBot

In your `Gemfile`, you have `factory_bot_rails`. Factories define blueprints for your models so you don't have to manually build them with `User.create!` every time.

Factories are defined in `spec/factories/`.
```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name  { "Doe" }
    email      { "user@example.com" }
  end
end
```

In your specs, you can use:
*   `build(:user)`: Instantiates a new record in memory (does not save to database). Fast!
*   `create(:user)`: Instantiates and saves the record to the database. Slower, but necessary for database queries.

---

## 5. Mocks and Stubs (Doubles)

When testing services (like your `StripePaymentService`), you don't want to hit the actual external Stripe API. Instead, you "stub" or "mock" the call.

*   **Double**: A dummy object that stands in for a real object.
*   **Stubbing**: Telling an object (real or double) to return a specific value when a method is called.

```ruby
it "charges the card successfully" do
  # Stubbing: Force the Stripe API wrapper to return a mock response
  allow(Stripe::Charge).to receive(:create).and_return(double(status: "succeeded"))
  
  service = StripePaymentService.new
  result = service.charge(amount: 100)
  
  expect(result.status).to eq("succeeded")
end
```
