import logging
import pprint
import json
from datetime import date, timedelta
from fints.client import FinTS3PinTanClient

print('Getting transactions...')

pp = pprint.PrettyPrinter(indent=4)
logging.basicConfig(level=logging.DEBUG)

with open('credentials.json') as raw:
    credentials = json.load(raw)["banking"]

client = FinTS3PinTanClient(
    '20050550',  # Bank BLZ
    credentials["login"], 
    credentials["pin"],
    'https://banking.haspa.de/OnlineBankingFinTS/pintan' # endpoint
)

accounts = client.get_sepa_accounts()
statement = client.get_statement(accounts[0], date.today() - timedelta(90), date.today())
balance = client.get_balance(accounts[0])

print('\n\nGot transactions from SEPA Account:', accounts)

for transaction in statement:
    print('\n\n=============================')
    print('Transaction date:', transaction.data.get('date', 'Not given').strftime('%m/%d/%Y'))
    print('Applicant:', transaction.data.get('applicant_name', 'Not given'))
    print('Purpose:', transaction.data.get('purpose', 'Not given'))
    print('Amount:', transaction.data.get('amount', 'Not given').amount, transaction.data['amount'].currency)
    print('=============================')

print('\n\nAnd the balance is', balance.amount.amount, balance.amount.currency)

input("\n\nPress enter to exit..")
