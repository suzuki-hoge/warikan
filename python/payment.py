def calculate(billingAmount, paymentSections, adjustingUnitAmount):
    divideNumber = len(paymentSections)
    (sharingAmount, fractionAmount) = divide(billingAmount, divideNumber, adjustingUnitAmount)
    print 'divide: ',
    print (sharingAmount, fractionAmount)
    units = adjustByUnit(paymentSections)
    print 'units: ',
    print units
    return (sharing(sharingAmount, adjustingUnitAmount, divideNumber, units), fractionAmount)


def divide(billingAmount, divideNumber, adjustingUnitAmount):
    sharing = billingAmount / divideNumber / adjustingUnitAmount * divideNumber * adjustingUnitAmount
    if sharing == 0:
        raise BaseException('unsharable adjusting unit amount')
    else:
        return (sharing, billingAmount - sharing)


def adjustByUnit(paymentSections):
    def get_lcm(x, y):
        import fractions
        return (x * y) // fractions.gcd(x, y)

    def morePresent():
        def point(paymentSection):
            return {'M': 1, 'N': -1, 'L': -2}[paymentSection]
        
        def adjust(lcm, plus, minus, paymentSection):
            return {'M': ('M', lcm / plus), 'N': ('N', lcm / minus), 'L': ('L', lcm / minus * 2)}[paymentSection]

        return (point, adjust)

    def moreMissing():
        def point(paymentSection):
            return {'N': 1, 'L': -1}[paymentSection]
        
        def adjust(lcm, plus, minus, paymentSection):
            return {'N': ('N', lcm / plus), 'L': ('L', lcm / minus)}[paymentSection]

        return (point, adjust)

    (pointer, adjuster) = morePresent() if 'M' in paymentSections else moreMissing()

    plus  = sum(filter(lambda n: n > 0, map(pointer, paymentSections)))
    minus = sum(filter(lambda n: n < 0, map(pointer, paymentSections)))
    lcm = get_lcm(plus, minus)

    return [adjuster(lcm, plus, minus, paymentSection) for paymentSection in list(set(paymentSections))]


def sharing(sharingAmount, adjustingUnitAmount, divideNumber, units):
    def fix(ave, adjustingUnitAmount, adjustingUnitCount):
        return adjustingUnitAmount * adjustingUnitCount + ave

    ave = sharingAmount / divideNumber
    fixed = [(paymentSection, fix(ave, adjustingUnitAmount, adjustingUnitCount)) for (paymentSection, adjustingUnitCount) in units]

    if all([paymentAmount >= 0 for (paymentSection, paymentAmount) in fixed]):
        return fixed
    else:
        raise BaseException('too large adjusting unit amount')


# print divide(1000, 3, 100) # 900, 100
# print divide(1199, 3, 100) # 900, 299
# print divide(1200, 3, 500) # unsharable adjusting unit amount

# print adjustByUnit(['M', 'M', 'M', 'N', 'L', 'L']) #  5, -3, -6
# print adjustByUnit(['M', 'N'])                     #  1, -1
# print adjustByUnit(['N', 'L'])                     #  1, -1

# print sharing(  900,  100, 3, [('M', 3), ('N', -1), ('L', -2)]) #   600,  200,  100
# print sharing(60000, 1000, 6, [('M', 5), ('N', -3), ('L', -6)]) # 15000, 7000, 4000
# print sharing( 6000, 1000, 6, [('M', 5), ('N', -3), ('L', -6)]) # too large adjusting unit amount

# print calculate(  900, ['M', 'N', 'L'], 100) # 600, 200, 100,  0
# print calculate(  990, ['M', 'N', 'L'], 100) # 600, 200, 100, 90
# print calculate(65000, ['M', 'M', 'M', 'N', 'L', 'L'], 500) # 13000, 9000, 7500
