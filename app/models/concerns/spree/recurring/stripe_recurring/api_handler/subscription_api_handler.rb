module Spree
  class Recurring < Spree::Base
    class StripeRecurring < Spree::Recurring
      module ApiHandler
        module SubscriptionApiHandler
          def subscribe(subscription_plan)
            raise_invalid_object_error(subscription_plan, Spree::SubscriptionPlan)
            customer = subscription_plan.user.find_or_create_stripe_customer(subscription_plan.card_token)

            begin
              stripe_subscription = Stripe::Subscription.create(
                                      customer: customer.id,
                                      items: [
                                        {
                                          plan: subscription_plan.plan.api_plan_id
                                        },
                                      ]
                                    )

              subscription_plan.stripe_subscription_id =  stripe_subscription.id # add stripe subscription id to subscription
            rescue => e
              false
            end
          end

          def unsubscribe(subscription_plan)
            raise_invalid_object_error(subscription_plan, Spree::SubscriptionPlan)

            begin
              stripe_subscription = Stripe::Subscription.retrieve(subscription_plan.stripe_subscription_id)
              stripe_subscription.delete
            rescue => e
              false
            end
          end
        end
      end
    end
  end
end