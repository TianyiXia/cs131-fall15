import java.util.concurrent.atomic.AtomicInteger;

class BetterSorryState implements State {
	private AtomicInteger[] value;
	private byte maxval;

	BetterSorryState(byte[] v) {
		value = new AtomicInteger[v.length];
		for (int i = 0; i < v.length; i++) {
			value[i] = new AtomicInteger[v[i]];
		}
		maxval = 127;
	}

	BetterSorryState(byte[] v, byte m) { 
		value = new AtomicInteger[v.length];
		for (int i = 0; i < v.length; i++) {
			value[i] = new AtomicInteger[v[i]];
		}
		maxval = m;
	}

	public int size() { return value.length; }

	public byte[] current() {
		byte[] current = new byte[value.length];
		for (int i = 0; i < v.length; i++) {
			current[i] = (byte) value[i].intValue();
		}
		return value;
	}

	public boolean swap(int i, int j) {
		if (value[i].get() <= 0 || value[j].get() >= maxval) {
			return false;
		}
		value[i].getAndDecrement();
		value[j].getAndIncrement();
		return true;
	} 
}