import sys, traceback
import getopt
import string
import serial as SE
import time
import re

#Function codes
ADD, SUB, MUL, DIV, NOR, XOR, OR, AND, SLL, SLA, SRL, SRA = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
Z, N, V, C = 1, 2, 4, 8
MAX_INT, MIN_INT = int(2**31-1), int(-(2**31))

#Read test data from file test_data.txt, by evaluating each line in the file.
#Each line in the file must be a call to the constructor of the TestData class,
#which is defined further down in the file
def read_test_data():
    tests = []
    print 'Loading tests...'
    with open('test_data.txt', 'r') as f:
        for line in f:
            tests.append(eval(line))
    print 'Tests loaded\n'
    return tests

#Helper function derived from the original script, used to output correctly
#formatted numbers to the FPGA driver
def write_argument(ser, arg):
    x = arg
    s = ''
    data = str(hex(int(x,16) | 0x100000000))
    data = data.replace('0x1','')
    data = data.replace('L','')
    d1 = int(data[0:2],16)
    d2 = int(data[2:4],16)
    d3 = int(data[4:6],16)
    d4 = int(data[6:8],16)

    if d1 == 0:
        s = s + chr(255) + chr(254)
    elif d1 == 255:
        s = s + chr(255) + chr(255)
    else:
        s = s + chr(d1)

    if d2 == 0:
        s = s + chr(255) + chr(254)
    elif d2 == 255:
        s = s + chr(255) + chr(255)
    else:
        s = s + chr(d2)

    if d3 == 0:
        s = s + chr(255) + chr(254)
    elif d3 == 255:
        s = s + chr(255) + chr(255)
    else:
        s = s + chr(d3)

    if d4 == 0:
        s = s + chr(255) + chr(254)
    elif d4 == 255:
        s = s + chr(255) + chr(255)
    else:
        s = s + chr(d4)
        
    ser.flush()
    time.sleep(0.1)
    ser.write(s)

#Thrown when a test fails
class TestException(Exception):
    def __init__(self, msg):
        self.msg = msg

    def __str__(self):
        return self.msg

#Handle input numbers of both hexadecimal and decimal formats
def parse_arg(arg):
    return str(hex(arg)).replace('L', '') if arg >= 0 else str(hex(((abs(arg) ^ 0xffffffff) + 1) & 0xffffffff)).replace('L', '')
    
class TestData:
    def __init__(self, f, a, b, out, status):
        self.f = parse_arg(f)
        self.a = parse_arg(a)
        self.b = parse_arg(b)
        #Handle unsigned output
        self.out = out if out <= MAX_INT else MIN_INT+(out&MAX_INT)
        self.status = status

    #Run this test
    def run_test(self, ser):
        write_argument(ser, self.f)
        write_argument(ser, self.a)
        write_argument(ser, self.b)

        i1 = ser.readline()
        i1 = i1.rstrip()
        print i1
        
        time.sleep(0.1)
        i1 = ser.readline()
        i1 = i1.rstrip()
        print i1

        print 'expected out={0}, status={1}'.format(self.out, self.status),

        m = re.match('ALU returned result=(.+), status=(.+)', i1)
        
        if int(m.group(1)) == self.out and int(m.group(2)) == self.status:
            print 'OK!'
        else:
            raise TestException('\n\n*****\nError in {0}!\n****\n'.format(self))

    def __str__(self):
        return 'Test(fun={0}, a={1}, b={2}, out={3}, status={4})'\
               .format(self.f, self.a, self.b, self.out, self.status)

    def __repr__(self):
        return str(self)

COM = '\\.\COM5'

tests = read_test_data()

#Added option 'k' for not stopping after the first test that fails
try:
    options, xarguments = getopt.getopt(sys.argv[1:],'p:k')
except getopt.error:
    print 'Error: You tried to use an unknown option or the argument for an option that requires it was missing. Try -h for more information.'
    sys.exit(0)

        
""" set COM port, COM5 otherwise """
for a in options[:]:
    if a[0] == '-p' and a[1] != '':
        COM = '\\.\COM' + a[1]
        options.remove(a)
        break
    elif a[0] == '-p' and a[1] == '':
        print '-p expects an argument'
        sys.exit(0)

keep_going = False
for a in options[:]:
    if a[0] == '-k':
        keep_going = True            

try:
    ser = SE.Serial(port=COM, baudrate=115200, bytesize=SE.EIGHTBITS, parity=SE.PARITY_NONE, stopbits=SE.STOPBITS_ONE, timeout=1)
except SE.SerialException:
    print 'COM port unknown'
    sys.exit(0)
    
if ser.isOpen():
    print 'port opened'
    tests_passed, test_count = 0, 0
    for test in tests:
        test_count += 1
        try:
            test.run_test(ser)
            if keep_going:
                tests_passed += 1
        except TestException as te:
            print te
            if not keep_going:
                ser.close()
                sys.exit(0)
        except:
            ser.close()
            traceback.print_exc(file=sys.stdout)
            print 'error in test {0}, closing port'.format(test)
            sys.exit(0)

    ser.close()
    if keep_going:
        print tests_passed, '/', test_count, '( ', \
              tests_passed*100.0/ test_count, ' %) of tests passed'
    else:
        print '\n********************\nAll tests passed!\n********************'
    print 'port closed'
    sys.exit(0)
else:
    print 'error opening port'
    sys.exit(0)


    

