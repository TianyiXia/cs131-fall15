import java.util.concurrent.atomic.AtomicInteger;

class BetterSorryState implements State {
	private byte[] value;
	private byte maxval;

	BetterSorryState(byte[] v) { value = v; maxval = 127; }

	BetterSorryState(byte[] v, byte m) { value = v; maxval = m; }

	public int size() { return value.length; }

	public byte[] current() { return value; }

	public boolean swap(int i, int j) {
		if (value[i] <= 0 || value[j] >= maxval) {
			return false;
		}
		AtomicInteger aii = new AtomicInteger(value[i]);
		AtomicInteger aij = new AtomicInteger(value[j]);
		value[i] = (byte) aii.getAndDecrement();
		value[j] = (byte) aij.getAndIncrement();
		return true;
	} 
}