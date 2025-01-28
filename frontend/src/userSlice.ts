import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  id: null,
  username: '',
  creditBalance: 0,
};

const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: {
    setUser(state: any, action: any) {
      state.id = action.payload.id;
      state.username = action.payload.username;
      state.creditBalance = action.payload.creditBalance;
    },
    updateCreditBalance(state: any, action: any) {
      state.creditBalance = action.payload;
    },
    clearUser(state: any) {
      state.id = null;
      state.username = '';
      state.creditBalance = 0;
    },
  },
});

export const { setUser, updateCreditBalance, clearUser } = userSlice.actions;
export default userSlice.reducer;