from brownie import AddAndSubtract, accounts

def deploy():
    account = accounts[0]
    AddAndSubtract.deploy({"from": account})

def main():
    deploy()